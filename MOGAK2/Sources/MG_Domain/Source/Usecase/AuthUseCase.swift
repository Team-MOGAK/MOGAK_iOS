import Foundation

/// 로그인 세션(토큰 저장, 로그인 상태)을 관리한다. 화면은 이 UseCase만 호출한다.
@MainActor
final class AuthUseCase {
    private let repository: AuthRepository
    private let storage: SessionStorage
    private let socialTokenProvider: SocialTokenProvider
    private let userState: MG2UserState

    init(repository: AuthRepository, storage: SessionStorage, socialTokenProvider: SocialTokenProvider, userState: MG2UserState) {
        self.repository = repository
        self.storage = storage
        self.socialTokenProvider = socialTokenProvider
        self.userState = userState
    }

    var isFirstLaunch: Bool { storage.isFirstTime }

    func completeOnboarding() {
        storage.setFirstTime(false)
    }

    /// 저장된 토큰으로 로그인 상태를 되살린다. 저장된 토큰이 없으면 아무것도 하지 않는다.
    func restoreSession() async {
        guard storage.refreshToken?.isEmpty == false else { return }

        do {
            _ = try await refreshAccessToken()
            storage.setFirstTime(false)
            userState.isRegistered = storage.storedUserIsRegistered ?? true
            userState.loginState = .login
        } catch {
            storage.clearAuthentication()
            userState.isRegistered = false
            userState.loginState = .logout
        }
    }

    func continueAsGuest() {
        userState.loginState = .guest
    }

    func login(provider: MG2SocialLoginProvider) async throws {
        let token = try await socialTokenProvider.token(for: provider)
        let session = try await repository.login(provider: provider, token: token)
        storage.saveSession(tokens: session.tokens, userID: session.userId, isRegistered: session.isRegistered)
        userState.isRegistered = session.isRegistered
        userState.loginState = .login
    }

    /// 새 액세스 토큰을 받아 저장한다. 저장된 리프레시 토큰이 없으면 nil.
    func refreshAccessToken() async throws -> String? {
        guard let refreshToken = storage.refreshToken, !refreshToken.isEmpty else { return nil }
        let tokens = try await repository.refresh(refreshToken: refreshToken)
        storage.saveTokens(tokens)
        return tokens.accessToken
    }

    func logout() async throws {
        try await repository.logout()
        storage.clearAuthentication()
        signOut()
    }

    /// 탈퇴 성공은 204라 본문이 없다. 성공하면 기기에 남은 인증 정보를 지운다.
    func withdraw() async throws {
        try await repository.withdraw()
        storage.resetAfterWithdrawal()
        signOut()
    }

    private func signOut() {
        userState.loginState = .logout
        userState.isRegistered = false
        userState.resetProfile()
    }
}
