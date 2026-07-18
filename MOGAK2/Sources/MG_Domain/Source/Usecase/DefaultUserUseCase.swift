import Foundation

final class DefaultUserUseCase: UserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func verifyNickname(_ nickname: String) async throws {
        try await repository.verifyNickname(nickname)
    }

    func changeNickname(_ nickname: String) async throws {
        try await repository.changeNickname(nickname)
    }

    func changeJob(_ job: String) async throws {
        try await repository.changeJob(job)
    }

    func getUserProfile() async throws -> MG2UserProfileEntity {
        try await repository.getUserProfile()
    }

    func userJoin(registration: MG2UserRegistration, profileImageData: Data?) async throws -> MG2UserRegistrationResult {
        try await repository.userJoin(registration: registration, profileImageData: profileImageData)
    }

    func userImageChange(imageData: Data, userNickname: String) async throws {
        try await repository.userImageChange(imageData: imageData, userNickname: userNickname)
    }
}
