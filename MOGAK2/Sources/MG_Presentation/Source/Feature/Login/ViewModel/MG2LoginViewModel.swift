import Foundation

struct MG2LoginViewState {
    var isLoading = false
    var errorMessage: String?
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
        state.errorMessage = nil
        notifyStateChange()

        Task {
            do {
                try await authUseCase.login(provider: provider)
                state.isLoading = false
                notifyStateChange()
                completion()
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
