import UIKit

@MainActor
final class MG2AlertCoordinator {
    /// onRetry가 있으면 버튼이 "다시 시도"가 되고, 누르면 다시 부른다.
    func presentError(_ error: Error, from source: UIViewController, onRetry: (() -> Void)? = nil) {
        present(title: "요청 실패", message: error.localizedDescription, actionTitle: onRetry == nil ? "닫기" : "다시 시도", from: source, onDismiss: onRetry)
    }

    func presentInfo(title: String, message: String?, from source: UIViewController, onDismiss: (() -> Void)? = nil) {
        present(title: title, message: message, from: source, onDismiss: onDismiss)
    }

    private func present(title: String, message: String?, actionTitle: String = "닫기", from source: UIViewController, onDismiss: (() -> Void)? = nil) {
        guard source.presentedViewController == nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in onDismiss?() })
        source.present(alert, animated: true)
    }
}
