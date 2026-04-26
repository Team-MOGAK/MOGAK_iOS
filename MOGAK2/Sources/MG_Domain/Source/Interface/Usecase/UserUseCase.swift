import Foundation

protocol UserUseCase {
    func verifyNickname(_ nickname: String) async throws -> NicknameVerify
    func changeNickname(_ nickname: String) async throws -> ChangeSuccessResponse
    func changeJob(_ job: String) async throws -> UserInfoChangeResponse
    func getUserProfile() async throws -> MG2UserProfileEntity
    func userJoin(userData: UserInfoData, profileImageData: Data?) async throws -> Bool
    func userImageChange(imageData: Data, userNickname: String) async throws -> Bool
}
