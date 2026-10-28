import SnapKit
import UIKit

extension UIControl {
    private static let loadingTag = 0x10AD

    /// 누른 작업이 끝날 때까지 이 컨트롤 안에 로딩을 보여 주고 다시 못 누르게 한다.
    /// 버튼은 글자 · 아이콘 자리에 로딩이 보이고, 다른 컨트롤(설정 행 등)은 오른쪽 끝에 로딩이 붙는다.
    func setLoading(_ isLoading: Bool) {
        isUserInteractionEnabled = !isLoading
        if let button = self as? UIButton, button.configuration != nil {
            button.configuration?.showsActivityIndicator = isLoading
            return
        }
        viewWithTag(Self.loadingTag)?.removeFromSuperview()
        let button = self as? UIButton
        button?.titleLabel?.alpha = isLoading ? 0 : 1
        button?.imageView?.alpha = isLoading ? 0 : 1
        guard isLoading else { return }

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.tag = Self.loadingTag
        indicator.color = button?.titleColor(for: .normal) ?? DS.Color.sub
        indicator.startAnimating()
        addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            if button != nil { $0.centerX.equalToSuperview() } else { $0.trailing.equalToSuperview().inset(16) }
        }
    }
}
