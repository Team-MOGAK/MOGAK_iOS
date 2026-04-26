import Foundation

final class DefaultUserUseCase: UserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func verifyNickname(_ nickname: String) async throws -> NicknameVerify {
        try await repository.verifyNickname(nickname)
    }

    func changeNickname(_ nickname: String) async throws -> ChangeSuccessResponse {
        try await repository.changeNickname(nickname)
    }

    func changeJob(_ job: String) async throws -> UserInfoChangeResponse {
        try await repository.changeJob(job)
    }

    func getUserProfile() async throws -> MG2UserProfileEntity {
        try await repository.getUserProfile()
    }

    func userJoin(userData: UserInfoData, profileImageData: Data?) async throws -> Bool {
        try await repository.userJoin(userData: userData, profileImageData: profileImageData)
    }

    func userImageChange(imageData: Data, userNickname: String) async throws -> Bool {
        try await repository.userImageChange(imageData: imageData, userNickname: userNickname)
    }
}
