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
    private let refreshAccessToken: () async throws -> String?

    init(
        session: Session = .default,
        accessTokenProvider: @escaping () -> String? = { nil },
        refreshAccessToken: @escaping () async throws -> String? = { nil }
    ) {
        self.session = session
        self.accessTokenProvider = accessTokenProvider
        self.refreshAccessToken = refreshAccessToken
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

        if target.requiresAuthorization,
           response.error == nil,
           response.response?.statusCode == 401,
           let refreshedAccessToken = try await refreshAccessToken(),
           !refreshedAccessToken.isEmpty {
            var retryRequest = try target.makeURLRequest()
            retryRequest.setValue(
                "Bearer \(refreshedAccessToken)",
                forHTTPHeaderField: "Authorization"
            )
            let retryResponse = await session.request(retryRequest).serializingData().response
            return try validatedData(from: retryResponse)
        }

        return try validatedData(from: response)
    }

    private func authenticatedURLRequest(for target: NetworkRequest) throws -> URLRequest {
        var urlRequest = try target.makeURLRequest()
        if target.requiresAuthorization,
           urlRequest.value(forHTTPHeaderField: "Authorization") == nil,
           let accessToken = accessTokenProvider(),
           !accessToken.isEmpty {
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
            let fallbackMessage = responseBody.isEmpty
                ? HTTPURLResponse.localizedString(forStatusCode: statusCode)
                : responseBody
            let message = payload?.message ?? fallbackMessage

            if statusCode == 429 {
                throw MG2NetworkError.rateLimited(message: message)
            }
            if statusCode == 503, payload?.code == "Z006" {
                throw MG2NetworkError.storageUnavailable(message: message)
            }
            throw MG2NetworkError.httpFailure(
                statusCode: statusCode,
                code: payload?.code,
                message: message
            )
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
