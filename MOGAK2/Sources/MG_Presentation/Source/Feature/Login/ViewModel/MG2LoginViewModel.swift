import Foundation

final class MG2LoginViewModel {
    private let appleLoginManage: MG2AppleLoginManage

    init(appleLoginManage: MG2AppleLoginManage = .shared) {
        self.appleLoginManage = appleLoginManage
    }

    func continueAsGuest() {
        MG2Deps.app.userState.loginState = .guest
    }

    func startAppleLogin() {
        appleLoginManage.startSignInWithAppleFlow()
    }
}
