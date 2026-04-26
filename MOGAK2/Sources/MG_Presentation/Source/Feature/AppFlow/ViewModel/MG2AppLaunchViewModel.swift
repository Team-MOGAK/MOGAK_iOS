import Foundation

enum MG2AppLaunchRoute {
    case login
    case terms
    case main
    case onboarding
}

final class MG2AppLaunchViewModel {
    func resolveRoute(loginState: LoginStatus?) -> MG2AppLaunchRoute {
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""

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

            return refreshToken.isEmpty ? .login : .main
        }

        if Storage.isFirstTime() {
            return .onboarding
        }

        return refreshToken.isEmpty ? .login : .main
    }
}
