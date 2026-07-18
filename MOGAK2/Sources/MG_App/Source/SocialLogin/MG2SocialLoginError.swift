import Foundation

enum MG2SocialLoginError: LocalizedError {
    case configurationMissing(provider: String)
    case presentingViewControllerNotFound
    case tokenMissing(provider: String)
    case nonceGenerationFailed
    case unsupportedAppleCredential
    case loginAlreadyInProgress

    var errorDescription: String? {
        switch self {
        case .configurationMissing(let provider):
            return "\(provider) login configuration is missing"
        case .presentingViewControllerNotFound:
            return "Presenting view controller was not found"
        case .tokenMissing(let provider):
            return "\(provider) login token is missing"
        case .nonceGenerationFailed:
            return "Apple login nonce generation failed"
        case .unsupportedAppleCredential:
            return "Apple returned an unsupported credential"
        case .loginAlreadyInProgress:
            return "Social login is already in progress"
        }
    }
}
