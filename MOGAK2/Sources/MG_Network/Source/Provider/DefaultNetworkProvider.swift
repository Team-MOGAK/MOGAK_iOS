//
//  DefaultNetworkProvider.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

struct DefaultNetworkProvider: NetworkProvider {
    private struct ErrorPayload: Decodable {
        let code: String?
        let message: String?
    }

    private let session: Session
    private let accessTokenProvider: () -> String?
    private let tokenRefresh: MG2TokenRefreshCoordinator

    init(session: Session = .default, accessTokenProvider: @escaping () -> String? = { nil }, refreshAccessToken: @escaping @MainActor () async throws -> String? = { nil }) {
        self.session = session
        self.accessTokenProvider = accessTokenProvider
        tokenRefresh = MG2TokenRefreshCoordinator(refresh: refreshAccessToken)
    }

    func request<T>(target: NetworkRequest) async throws -> T where T: Decodable {
        let data = try await responseData(target: target)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func requestEmpty(target: NetworkRequest) async throws {
        _ = try await responseData(target: target)
    }

    private func responseData(target: NetworkRequest) async throws -> Data {
        let urlRequest = try authenticatedURLRequest(for: target)
        let response = await session.request(urlRequest).serializingData().response

        if target.requiresAuthorization, requiresTokenRefresh(response), let refreshedAccessToken = try await tokenRefresh.refreshAccessToken(), !refreshedAccessToken.isEmpty {
            var retryRequest = try target.makeURLRequest()
            retryRequest.setValue("Bearer \(refreshedAccessToken)", forHTTPHeaderField: "Authorization")
            let retryResponse = await session.request(retryRequest).serializingData().response
            return try validatedData(from: retryResponse)
        }

        return try validatedData(from: response)
    }

    /// 401은 만료된 토큰, 403 T006은 가입 완료 전에 받은 토큰이다. 둘 다 갱신 후 한 번만 재시도한다.
    private func requiresTokenRefresh(_ response: AFDataResponse<Data>) -> Bool {
        guard response.error == nil, let statusCode = response.response?.statusCode else { return false }
        if statusCode == 401 { return true }
        guard statusCode == 403, let data = response.data else { return false }
        return (try? JSONDecoder().decode(ErrorPayload.self, from: data))?.code == "T006"
    }

    private func authenticatedURLRequest(for target: NetworkRequest) throws -> URLRequest {
        var urlRequest = try target.makeURLRequest()
        if target.requiresAuthorization, urlRequest.value(forHTTPHeaderField: "Authorization") == nil, let accessToken = accessTokenProvider(), !accessToken.isEmpty {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }

    private func validatedData(from response: AFDataResponse<Data>) throws -> Data {
        let statusCode = response.response?.statusCode ?? -1
        let url = response.request?.url?.absoluteString ?? "unknown-url"
        let data = response.data ?? Data()
        let responseBody = String(data: data, encoding: .utf8) ?? ""

        if let error = response.error {
            logFailure(kind: "Error", url: url, statusCode: statusCode, responseBody: responseBody)
            throw error
        }

        guard (200..<300).contains(statusCode) else {
            logFailure(kind: "Non2xx", url: url, statusCode: statusCode, responseBody: responseBody)
            let payload = try? JSONDecoder().decode(ErrorPayload.self, from: data)
            let fallbackMessage = responseBody.isEmpty ? HTTPURLResponse.localizedString(forStatusCode: statusCode) : responseBody
            let message = payload?.message ?? fallbackMessage

            if statusCode == 429 {
                throw MG2NetworkError.rateLimited(message: message)
            }
            if statusCode == 503, payload?.code == "Z006" {
                throw MG2NetworkError.storageUnavailable(message: message)
            }
            throw MG2NetworkError.httpFailure(statusCode: statusCode, code: payload?.code, message: message)
        }

        return data
    }

    private func logFailure(kind: String, url: String, statusCode: Int, responseBody: String) {
#if DEBUG
        print("[Network][\(kind)] \(url)")
        print("[Network][Status] \(statusCode)")
        print("[Network][Body] \(responseBody)")
#endif
    }
}
