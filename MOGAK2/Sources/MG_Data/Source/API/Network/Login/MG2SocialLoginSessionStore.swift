import Foundation

enum MG2SocialLoginSessionStore {
    @MainActor
    static func apply(session: MG2AuthSession, email: String? = nil) {
        MG2TokenStore.save(
            accessToken: session.tokens.accessToken,
            refreshToken: session.tokens.refreshToken
        )
        UserDefaults.standard.set(session.userId, forKey: "userId")

        MG2Deps.app.userState.userIsRegistered = session.isRegistered
        if let email, !email.isEmpty {
            MG2Deps.app.userState.userEmail = email
        }
        MG2Deps.app.userState.loginState = .login
    }
}
