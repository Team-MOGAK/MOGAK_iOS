import Foundation

protocol UserUseCase {
    func verifyNickname(_ nickname: String) async throws
    func changeNickname(_ nickname: String) async throws
    func changeJob(_ job: String) async throws
    func getUserProfile() async throws -> MG2UserProfileEntity
    func userJoin(registration: MG2UserRegistration, profileImageData: Data?) async throws -> MG2UserRegistrationResult
    func userImageChange(imageData: Data, userNickname: String) async throws
}
