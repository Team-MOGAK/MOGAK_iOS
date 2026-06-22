import Foundation
import Alamofire

final class DefaultUserRepository: UserRepository {
    private var baseURL: String {
        let value = APIConfig.BaseURL
        return value.hasSuffix("/") ? value : value + "/"
    }

    private var shouldUploadProfileImage: Bool {
        guard let host = URL(string: baseURL)?.host?.lowercased() else { return true }
        return !["localhost", "127.0.0.1", "0.0.0.0", "::1"].contains(host)
    }

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func verifyNickname(_ nickname: String) async throws -> NicknameVerify {
        try await networkProvider.request(target: MG2UserRouter.nicknameVerify(nickname: nickname))
    }

    func changeNickname(_ nickname: String) async throws -> ChangeSuccessResponse {
        try await networkProvider.request(target: MG2UserRouter.nicknameChange(nickname: nickname))
    }

    func changeJob(_ job: String) async throws -> UserInfoChangeResponse {
        try await networkProvider.request(target: MG2UserRouter.jobChange(job: job))
    }

    func getUserProfile() async throws -> MG2UserProfileEntity {
        let response: MG2GetUserProfileResponseDTO = try await networkProvider.request(target: MG2UserRouter.getUserProfile)
        return response.result.toEntity()
    }

    func userJoin(userData: UserInfoData, profileImageData: Data?) async throws -> Bool {
        let url = baseURL + "api/users/join"
        let userId = UserDefaults.standard.integer(forKey: "userId")

        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data"
        ]
        if let accessToken = MG2TokenStore.accessToken, !accessToken.isEmpty {
            headers.add(.authorization(bearerToken: accessToken))
        }

        let parameter: [String: Any] = [
            "nickname": userData.nickname,
            "job": userData.job,
            "address": userData.address,
            "email": userData.email,
            "userId": userId
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                if let jsonData = try? JSONSerialization.data(withJSONObject: parameter) {
                    multipartFormData.append(jsonData, withName: "request", mimeType: "application/json")
                }

                if self.shouldUploadProfileImage, let imageData = profileImageData {
                    multipartFormData.append(
                        imageData,
                        withName: "multipartFile",
                        fileName: "\(userData.nickname)_\(Date().timeIntervalSince1970).jpeg",
                        mimeType: "image/jpeg"
                    )
                }
            }, to: url, method: .post, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserInfoDataResponse.self) { response in
                switch response.result {
                case .success:
                    continuation.resume(returning: true)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func userImageChange(imageData: Data, userNickname: String) async throws -> Bool {
        let url = baseURL + "api/users/profile/image"
        var headers: HTTPHeaders = [
            "Accept": "application/json, application/javascript, text/javascript, text/json",
            "Content-Type": "multipart/form-data"
        ]

        if let accessToken = MG2TokenStore.accessToken, !accessToken.isEmpty {
            headers.add(.authorization(bearerToken: accessToken))
        }

        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(
                    imageData,
                    withName: "multipartFile",
                    fileName: "\(userNickname).jpeg",
                    mimeType: "image/jpeg"
                )
            }, to: url, method: .put, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ChangeSuccessResponse.self) { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data.code == "success")
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
