import Foundation

/// 회원가입과 프로필 변경. 바뀐 값은 MG2UserState에 반영해서 화면이 구독한다.
@MainActor
final class UserUseCase {
    private let repository: UserRepository
    private let storage: SessionStorage
    private let userState: MG2UserState

    init(repository: UserRepository, storage: SessionStorage, userState: MG2UserState) {
        self.repository = repository
        self.storage = storage
        self.userState = userState
    }

    func getJobs() async throws -> [String] {
        try await repository.getJobs()
    }

    func getAddresses() async throws -> [String] {
        try await repository.getAddresses()
    }

    func getConsentItems() async throws -> [MG2ConsentItemEntity] {
        try await repository.getConsentItems()
    }

    func verifyNickname(_ nickname: String) async throws {
        try await repository.verifyNickname(nickname)
    }

    func loadProfile() async throws {
        let profile = try await repository.getUserProfile()
        userState.nickname = profile.nickname
        userState.job = profile.job
        userState.profileImageID = profile.profileImageID
    }

    func changeNickname(_ nickname: String) async throws {
        try await repository.changeNickname(nickname)
        userState.nickname = nickname
    }

    func changeJob(_ job: String) async throws {
        try await repository.changeJob(job)
        userState.job = job
    }

    func changeProfileImage(_ imageID: Int) async throws {
        try await repository.changeProfileImage(imageID)
        userState.profileImageID = imageID
    }

    /// 가입을 마치면 새 토큰을 저장하고 로그인 상태로 바꾼다.
    func join(_ registration: MG2UserRegistration) async throws {
        let result = try await repository.userJoin(registration: registration)
        storage.saveSession(tokens: result.tokens, userID: result.userId, isRegistered: true)
        if let profileImageID = registration.profileImageID {
            try await changeProfileImage(profileImageID)
        }
        userState.nickname = result.nickname
        storage.setFirstTime(false)
        userState.isRegistered = true
        userState.loginState = .login
    }
}
