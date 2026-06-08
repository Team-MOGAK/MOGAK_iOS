import Foundation

@MainActor
protocol MG2SocialLoginUseCase {
    func continueAsGuest()
    func startAppleLogin()
    func startGoogleLogin()
    func startKakaoLogin()
}

final class DefaultMG2SocialLoginUseCase: MG2SocialLoginUseCase {
    private let appleLoginManage: MG2AppleLoginManage
    private let googleLoginManage: MG2GoogleLoginManage
    private let kakaoLoginManage: MG2KakaoLoginManage

    init(authUseCase: AuthUseCase) {
        self.appleLoginManage = MG2AppleLoginManage(authUseCase: authUseCase)
        self.googleLoginManage = MG2GoogleLoginManage(authUseCase: authUseCase)
        self.kakaoLoginManage = MG2KakaoLoginManage(authUseCase: authUseCase)
    }

    func continueAsGuest() {
        MG2Deps.app.userState.loginState = .guest
    }

    func startAppleLogin() {
        appleLoginManage.startSignInWithAppleFlow()
    }

    func startGoogleLogin() {
        googleLoginManage.startGoogleLogin()
    }

    func startKakaoLogin() {
        kakaoLoginManage.startKakaoLogin()
    }
}

@MainActor
final class MG2LoginViewModel {
    private let useCase: MG2SocialLoginUseCase

    init(useCase: MG2SocialLoginUseCase) {
        self.useCase = useCase
    }

    func continueAsGuest() {
        useCase.continueAsGuest()
    }

    func startAppleLogin() {
        useCase.startAppleLogin()
    }

    func startGoogleLogin() {
        useCase.startGoogleLogin()
    }

    func startKakaoLogin() {
        useCase.startKakaoLogin()
    }
}
