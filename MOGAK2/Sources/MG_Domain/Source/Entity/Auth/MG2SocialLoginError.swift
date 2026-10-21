import Foundation

/// 소셜 SDK 로그인 실패. 화면에는 사유 없이 "로그인 실패"만 보여주고, 사용자가 취소한 경우는 아무것도 띄우지 않는다.
enum MG2SocialLoginError: Error, Equatable {
    case cancelled
    case configurationMissing(provider: String)
    case presentingViewControllerNotFound
    case tokenMissing(provider: String)
    case nonceGenerationFailed
    case unsupportedAppleCredential
    case loginAlreadyInProgress
}
