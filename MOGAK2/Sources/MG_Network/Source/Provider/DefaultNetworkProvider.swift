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
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logFailure(kind: "Decoding", url: "\(T.self)", statusCode: 200, responseBody: "\(error)")
            throw MG2NetworkError.requestFailed
        }
    }

    func requestEmpty(target: NetworkRequest) async throws {
        _ = try await responseData(target: target)
    }

    private func responseData(target: NetworkRequest) async throws -> Data {
        let urlRequest = try authenticatedURLRequest(for: target)
        let response = await session.request(urlRequest).serializingData().response

        if target.requiresAuthorization, requiresTokenRefresh(response), let refreshedAccessToken = try await tokenRefresh.refreshAccessToken(), !refreshedAccessToken.isEmpty {
            guard var retryRequest = try? target.makeURLRequest() else { throw MG2NetworkError.requestFailed }
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
        guard var urlRequest = try? target.makeURLRequest() else { throw MG2NetworkError.requestFailed }
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
            throw Self.networkError(from: error)
        }

        guard (200..<300).contains(statusCode) else {
            logFailure(kind: "Non2xx", url: url, statusCode: statusCode, responseBody: responseBody)
            if statusCode == 429 {
                let retryAfter = response.response?.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
                throw MG2NetworkError.rateLimited(retryAfter: retryAfter)
            }
            throw MG2NetworkError.httpFailure(statusCode: statusCode)
        }

        return data
    }

    private static func networkError(from error: AFError) -> MG2NetworkError {
        switch (error.underlyingError as? URLError)?.code {
        case .timedOut?:
            return .timeout
        case .notConnectedToInternet?, .networkConnectionLost?, .cannotFindHost?, .cannotConnectToHost?, .dataNotAllowed?, .internationalRoamingOff?:
            return .offline
        default:
            return .requestFailed
        }
    }

    private func logFailure(kind: String, url: String, statusCode: Int, responseBody: String) {
#if DEBUG
        print("[Network][\(kind)] \(url)")
        print("[Network][Status] \(statusCode)")
        print("[Network][Body] \(responseBody)")
#endif
    }
}
