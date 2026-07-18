import Foundation

final class DefaultUserRepository: UserRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func verifyNickname(_ nickname: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.nicknameVerify(nickname: nickname))
    }

    func changeNickname(_ nickname: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.nicknameChange(nickname: nickname))
    }

    func changeJob(_ job: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.jobChange(job: job))
    }

    func getUserProfile() async throws -> MG2UserProfileEntity {
        let response: MG2GetUserProfileResponseDTO = try await networkProvider.request(target: MG2UserRouter.getUserProfile)
        return response.result.toEntity()
    }

    func userJoin(
        registration: MG2UserRegistration,
        profileImageData: Data?
    ) async throws -> MG2UserRegistrationResult {
        let requestData = try JSONEncoder().encode(
            MG2UserRegistrationRequestDTO(
                nickname: registration.nickname,
                job: registration.job,
                address: registration.address
            )
        )
        var parts = [
            NetworkMultipartPart(
                data: requestData,
                name: "request",
                mimeType: "application/json"
            )
        ]

        if let profileImageData {
            parts.append(
                NetworkMultipartPart(
                    data: profileImageData,
                    name: "multipartFile",
                    fileName: "\(registration.nickname)_\(Date().timeIntervalSince1970).jpeg",
                    mimeType: "image/jpeg"
                )
            )
        }

        let response: MG2UserRegistrationResponseDTO = try await networkProvider.upload(
            target: MG2UserRouter.join,
            parts: parts
        )
        return response.result.toEntity()
    }

    func userImageChange(imageData: Data, userNickname: String) async throws {
        try await networkProvider.uploadEmpty(
            target: MG2UserRouter.profileImageChange,
            parts: [
                NetworkMultipartPart(
                    data: imageData,
                    name: "multipartFile",
                    fileName: "\(userNickname).jpeg",
                    mimeType: "image/jpeg"
                )
            ]
        )
    }
}
