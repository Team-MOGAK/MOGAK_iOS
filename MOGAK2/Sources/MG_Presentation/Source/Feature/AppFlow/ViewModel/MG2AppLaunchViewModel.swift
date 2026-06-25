import Foundation

enum MG2AppLaunchRoute {
    case login
    case terms
    case main
    case onboarding
}

final class MG2AppLaunchViewModel {
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func resolveInitialRoute() async -> MG2AppLaunchRoute {
        guard let refreshToken = MG2TokenStore.refreshToken, !refreshToken.isEmpty else {
            return defaultRoute
        }

        do {
            let tokens = try await authUseCase.refresh(refreshToken: refreshToken)
            MG2TokenStore.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
            MG2LaunchStorage.setFirstTime(false)

            let isRegistered = MG2LaunchStorage.storedUserIsRegistered ?? true
            await updateSessionState(isRegistered: isRegistered, loginState: .login)

            return isRegistered ? .main : .terms
        } catch {
            MG2TokenStore.clearTokens()
            MG2LaunchStorage.clearUserRegistration()
            await updateSessionState(isRegistered: false, loginState: .logout)

            return defaultRoute
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

            return defaultRoute
        }

        return defaultRoute
    }

    private var defaultRoute: MG2AppLaunchRoute {
        MG2LaunchStorage.isFirstTime ? .onboarding : .login
    }

    @MainActor
    private func updateSessionState(isRegistered: Bool, loginState: LoginStatus) {
        MG2Deps.app.userState.userIsRegistered = isRegistered
        MG2Deps.app.userState.loginState = loginState
    }
}
