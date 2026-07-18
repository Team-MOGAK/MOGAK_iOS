import Foundation

struct MG2LoginViewState {
    var isLoading = false
    var errorMessage: String?
}

@MainActor
final class MG2LoginViewModel {
    private let useCase: MG2SocialLoginUseCase
    private let userState: MG2UserState
    private let sessionStore: MG2SessionStoring
    private(set) var state = MG2LoginViewState()
    var onStateChange: ((MG2LoginViewState) -> Void)?

    init(
        useCase: MG2SocialLoginUseCase,
        userState: MG2UserState,
        sessionStore: MG2SessionStoring
    ) {
        self.useCase = useCase
        self.userState = userState
        self.sessionStore = sessionStore
    }

    func continueAsGuest() {
        guard !state.isLoading else { return }
        userState.loginState = .guest
    }

    func startAppleLogin(completion: (() -> Void)? = nil) {
        login(provider: .apple, completion: completion)
    }

    func startGoogleLogin(completion: (() -> Void)? = nil) {
        login(provider: .google, completion: completion)
    }

    func startKakaoLogin(completion: (() -> Void)? = nil) {
        login(provider: .kakao, completion: completion)
    }

    private func login(provider: MG2SocialLoginProvider, completion: (() -> Void)?) {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil
        notifyStateChange()

        Task {
            do {
                let session = try await useCase.login(provider: provider)
                sessionStore.saveSession(
                    accessToken: session.tokens.accessToken,
                    refreshToken: session.tokens.refreshToken,
                    userID: session.userId,
                    isRegistered: session.isRegistered
                )
                userState.isRegistered = session.isRegistered
                state.isLoading = false
                notifyStateChange()
                userState.loginState = .login
                completion?()
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                notifyStateChange()
            }
        }
    }

    func clearError() {
        state.errorMessage = nil
        notifyStateChange()
    }

    private func notifyStateChange() {
        onStateChange?(state)
    }
}
