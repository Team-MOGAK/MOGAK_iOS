import UIKit

extension UIViewController {
    /// 다음 화면 데이터를 먼저 불러오는 동안 부른다. 화면은 그대로 두고 누르기만 막는다.
    /// 0.25초가 넘을 때만 가운데에 작은 로딩을 띄운다 (덮개 없음). 돌려받은 함수를 부르면 끝난다.
    func beginPendingTransition() -> () -> Void {
        view.isUserInteractionEnabled = false
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = DS.Color.sub
        let show = DispatchWorkItem { [weak self] in
            guard let self else { return }
            indicator.alpha = 0
            let view: UIView = view
            view.addSubview(indicator)
            indicator.snp.makeConstraints { $0.center.equalTo(view.safeAreaLayoutGuide) }
            indicator.startAnimating()
            UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: show)
        return { [weak self] in
            show.cancel()
            indicator.removeFromSuperview()
            self?.view.isUserInteractionEnabled = true
        }
    }
}
