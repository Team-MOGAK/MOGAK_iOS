import Foundation

enum MG2SocialLoginURLHandler {
    @MainActor
    @discardableResult
    static func handle(_ url: URL) -> Bool {
        MG2KakaoLoginManager.handleOpenURL(url) || MG2GoogleLoginManager.handleOpenURL(url)
    }
}
