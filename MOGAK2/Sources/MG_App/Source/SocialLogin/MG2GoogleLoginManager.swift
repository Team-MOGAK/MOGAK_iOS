import Foundation
import GoogleSignIn
import UIKit

@MainActor
final class MG2GoogleLoginManager: MG2SocialTokenProviding {
    private static var clientID: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }
        return value
    }

    @discardableResult
    static func configureSDK() -> Bool {
        guard let clientID else { return false }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        return true
    }

    @discardableResult
    static func handleOpenURL(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    func token() async throws -> String {
        guard Self.configureSDK() else {
            throw MG2SocialLoginError.configurationMissing(provider: "Google")
        }
        guard let presentingViewController = UIApplication.shared.mg2TopViewController else {
            throw MG2SocialLoginError.presentingViewControllerNotFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let token = result?.user.idToken?.tokenString else {
                    continuation.resume(
                        throwing: MG2SocialLoginError.tokenMissing(provider: "Google")
                    )
                    return
                }
                continuation.resume(returning: token)
            }
        }
    }
}

private extension UIApplication {
    var mg2TopViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .mg2TopMostViewController
    }
}

private extension UIViewController {
    var mg2TopMostViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.mg2TopMostViewController
        }
        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.mg2TopMostViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.mg2TopMostViewController
        }
        return self
    }
}
