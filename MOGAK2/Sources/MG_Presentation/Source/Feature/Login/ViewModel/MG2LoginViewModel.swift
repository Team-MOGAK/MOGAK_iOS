import Foundation

struct MG2LoginViewState {
    var isLoading = false
    var isLoginFailed = false
}

@MainActor
final class MG2LoginViewModel {
    private let authUseCase: AuthUseCase
    private(set) var state = MG2LoginViewState()
    var onStateChange: ((MG2LoginViewState) -> Void)?

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func continueAsGuest() {
        guard !state.isLoading else { return }
        authUseCase.continueAsGuest()
    }

    func login(provider: MG2SocialLoginProvider, completion: @escaping () -> Void) {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.isLoginFailed = false
        notifyStateChange()

        Task {
            do {
                try await authUseCase.login(provider: provider)
                state.isLoading = false
                notifyStateChange()
                completion()
            } catch {
                state.isLoading = false
                // 사용자가 직접 취소했으면 실패 얼럿을 띄우지 않는다.
                state.isLoginFailed = (error as? MG2SocialLoginError) != .cancelled
                notifyStateChange()
            }
        }
    }

    func clearError() {
        state.isLoginFailed = false
        notifyStateChange()
    }

    private func notifyStateChange() {
        onStateChange?(state)
    }
}
