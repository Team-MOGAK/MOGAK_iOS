import UIKit

final class MG2CommonLoginGate {
    static func gotoLoginViewController(_ vc: UIViewController) {
        let gotoLoginAlertAction = UIAlertAction(title: "네", style: .default) { _ in
            let loginVC = MG2LoginViewController()
            loginVC.modalPresentationStyle = .overFullScreen
            vc.present(loginVC, animated: false)
        }

        let cancelAlertAction = UIAlertAction(title: "아니요", style: .cancel)

        let needLoginAlertController = UIAlertController(
            title: "로그인 필요",
            message: "해당 기능을 사용하시려면 로그인이 필요합니다. \n로그인 화면으로 이동하시겠습니까?",
            preferredStyle: .alert
        )

        needLoginAlertController.addAction(gotoLoginAlertAction)
        needLoginAlertController.addAction(cancelAlertAction)
        vc.present(needLoginAlertController, animated: false)
    }
}
