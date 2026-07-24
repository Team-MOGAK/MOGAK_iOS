protocol UserRepository {
    func verifyNickname(_ nickname: String) async throws
    func changeNickname(_ nickname: String) async throws
    func changeJob(_ job: String) async throws
    func getUserProfile() async throws -> MG2UserProfileEntity
    func userJoin(registration: MG2UserRegistration) async throws -> MG2UserRegistrationResult
}
