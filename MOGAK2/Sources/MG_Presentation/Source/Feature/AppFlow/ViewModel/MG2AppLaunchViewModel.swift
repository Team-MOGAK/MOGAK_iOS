import Foundation

enum MG2AppLaunchRoute {
    case login
    case terms
    case main
    case onboarding
}

@MainActor
final class MG2AppLaunchViewModel {
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func resolveInitialRoute() async -> MG2AppLaunchRoute {
        guard let refreshToken = MG2TokenStore.refreshToken, !refreshToken.isEmpty else {
            return Storage.isFirstTime() ? .onboarding : .login
        }

        do {
            let tokens = try await authUseCase.refresh(refreshToken: refreshToken)
            MG2TokenStore.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
            Storage.setFirstTime(false)
            MG2Deps.app.userState.userIsRegistered = true
            MG2Deps.app.userState.loginState = .login
            return .main
        } catch {
            MG2TokenStore.clearTokens()
            MG2Deps.app.userState.userIsRegistered = false
            MG2Deps.app.userState.loginState = .logout
            return Storage.isFirstTime() ? .onboarding : .login
        }
    }

    func resolveRoute(loginState: LoginStatus?) -> MG2AppLaunchRoute {
        if let loginState {
            if loginState == .login {
                return MG2Deps.app.userState.userIsRegistered ? .main : .terms
            }

            if loginState == .guest {
                return .main
            }

            if Storage.isFirstTime() {
                return .onboarding
            }

            return .login
        }

        if Storage.isFirstTime() {
            return .onboarding
        }

        return .login
    }
}
