//import Foundation
//import UIKit
//
//final class MG2GoogleLoginManage {
//    static var clientID: String {
//        Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String ?? ""
//    }
//
//    private let authUseCase: AuthUseCase
//
//    init(authUseCase: AuthUseCase) {
//        self.authUseCase = authUseCase
//    }
//
//    static func configureSDK() {
//        guard !clientID.isEmpty else {
//            print("[GoogleLogin] GIDClientID is missing")
//            return
//        }
//        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
//    }
//
//    @discardableResult
//    static func handleOpenUrl(_ url: URL) -> Bool {
//        GIDSignIn.sharedInstance.handle(url)
//    }
//
//    @MainActor
//    func startGoogleLogin() {
//        Self.configureSDK()
//
//        guard let presentingViewController = UIApplication.shared.mg2TopViewController else {
//            print("[GoogleLogin] presenting view controller not found")
//            return
//        }
//
//        let authUseCase = self.authUseCase
//        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
//            if let error {
//                print("[GoogleLogin] sign in failed: \(error.localizedDescription)")
//                return
//            }
//
//            guard let idToken = result?.user.idToken?.tokenString else {
//                print("[GoogleLogin] id token is missing")
//                return
//            }
//
//            let email = result?.user.profile?.email
//            Task {
//                do {
//                    let session = try await authUseCase.login(provider: .google, token: idToken)
//                    await MG2SocialLoginSessionStore.apply(session: session, email: email)
//                } catch {
//                    print("[GoogleLogin] backend login failed: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//private extension UIApplication {
//    var mg2TopViewController: UIViewController? {
//        connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap(\.windows)
//            .first { $0.isKeyWindow }?
//            .rootViewController?
//            .mg2TopMostViewController
//    }
//}
//
//private extension UIViewController {
//    var mg2TopMostViewController: UIViewController {
//        if let presentedViewController {
//            return presentedViewController.mg2TopMostViewController
//        }
//
//        if let navigationController = self as? UINavigationController,
//           let visibleViewController = navigationController.visibleViewController {
//            return visibleViewController.mg2TopMostViewController
//        }
//
//        if let tabBarController = self as? UITabBarController,
//           let selectedViewController = tabBarController.selectedViewController {
//            return selectedViewController.mg2TopMostViewController
//        }
//
//        return self
//    }
//}
