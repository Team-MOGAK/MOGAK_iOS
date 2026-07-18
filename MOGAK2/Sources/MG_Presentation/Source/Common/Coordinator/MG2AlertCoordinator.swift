import UIKit

@MainActor
final class MG2AlertCoordinator {
    func presentError(_ error: Error, from source: UIViewController) {
        present(
            title: "요청 실패",
            message: error.localizedDescription,
            from: source
        )
    }

    func presentInfo(
        title: String,
        message: String,
        from source: UIViewController,
        onDismiss: (() -> Void)? = nil
    ) {
        present(
            title: title,
            message: message,
            from: source,
            onDismiss: onDismiss
        )
    }

    private func present(
        title: String,
        message: String,
        from source: UIViewController,
        onDismiss: (() -> Void)? = nil
    ) {
        guard source.presentedViewController == nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            onDismiss?()
        })
        source.present(alert, animated: true)
    }
}
