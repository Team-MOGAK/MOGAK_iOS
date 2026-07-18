import Foundation

enum MG2AppLaunchRoute: Equatable {
    case login
    case terms
    case main
    case onboarding
}

final class MG2AppLaunchViewModel {
    private let authUseCase: AuthUseCase
    private let userState: MG2UserState
    private let sessionStore: MG2SessionStoring

    init(
        authUseCase: AuthUseCase,
        userState: MG2UserState,
        sessionStore: MG2SessionStoring
    ) {
        self.authUseCase = authUseCase
        self.userState = userState
        self.sessionStore = sessionStore
    }

    func resolveInitialRoute() async -> MG2AppLaunchRoute {
        guard let refreshToken = sessionStore.refreshToken, !refreshToken.isEmpty else {
            return defaultRoute
        }

        do {
            let tokens = try await authUseCase.refresh(refreshToken: refreshToken)
            sessionStore.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
            sessionStore.setFirstTime(false)

            let isRegistered = sessionStore.storedUserIsRegistered ?? true
            await updateSessionState(isRegistered: isRegistered, loginState: .login)

            return isRegistered ? .main : .terms
        } catch {
            sessionStore.clearAuthentication()
            await updateSessionState(isRegistered: false, loginState: .logout)

            return defaultRoute
        }
    }

    func resolveRoute(loginState: MG2LoginStatus?) -> MG2AppLaunchRoute {
        if let loginState {
            if loginState == .login {
                return userState.isRegistered ? .main : .terms
            }

            if loginState == .guest {
                return .main
            }

            return defaultRoute
        }

        return defaultRoute
    }

    func resolveCurrentRoute() -> MG2AppLaunchRoute {
        resolveRoute(loginState: userState.loginState)
    }

    func completeOnboarding() {
        sessionStore.setFirstTime(false)
    }

    private var defaultRoute: MG2AppLaunchRoute {
        sessionStore.isFirstTime ? .onboarding : .login
    }

    @MainActor
    private func updateSessionState(isRegistered: Bool, loginState: MG2LoginStatus) {
        userState.isRegistered = isRegistered
        userState.loginState = loginState
    }
}
