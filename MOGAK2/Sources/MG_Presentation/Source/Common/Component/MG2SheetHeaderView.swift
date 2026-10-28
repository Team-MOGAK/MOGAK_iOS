import SnapKit
import UIKit

/// 시트 머리 (`.md-sheet-head`): 44pt, 가운데 제목 17/800, 닫기는 항상 왼쪽 44pt(36 원 `fill` · `ink-3`).
/// 오른쪽에는 아무것도 두지 않고, 확정은 하단 주 버튼으로.
final class MG2SheetHeaderView: UIView {
    var onClose: (() -> Void)?

    init(title: String?) {
        super.init(frame: .zero)
        let titleLabel = UILabel()
        titleLabel.apply(.headline)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.accessibilityTraits = .header

        let closeButton = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold))
        configuration.baseBackgroundColor = DS.Color.fill
        configuration.baseForegroundColor = DS.Color.ink3
        // 누르는 영역 44, 보이는 원 36 (`.md-sheet-close span`).
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = DS.Size.chip / 2
        configuration.background.backgroundInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        configuration.contentInsets = .zero
        closeButton.configuration = configuration
        closeButton.accessibilityLabel = "닫기"
        closeButton.addAction(UIAction { [weak self] _ in self?.onClose?() }, for: .touchUpInside)

        addSubviews(titleLabel, closeButton)
        // 제목 17/800은 accessibility1(최대)에서도 줄 높이 약 34라 44 안에 들어간다.
        snp.makeConstraints { $0.height.equalTo(DS.Size.touch) }
        closeButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(DS.Size.touch)
        }
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(closeButton.snp.trailing).offset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    /// 시트 공통: `surface` 바탕, 위 모서리 `radius-sheet`, 손잡이 표시.
    func configureDesignSheet(height: CGFloat? = nil) {
        view.backgroundColor = DS.Color.surface
        modalPresentationStyle = .pageSheet
        guard let sheet = sheetPresentationController else { return }
        if let height {
            sheet.detents = [.custom { _ in height }]
        }
        sheet.preferredCornerRadius = DS.Radius.sheet
        sheet.prefersGrabberVisible = true
    }

    /// 내용 높이에 맞춘 시트. 가장 큰 높이를 넘으면 거기서 멈춘다. 내용이 바뀌면 `invalidateDetents()`.
    func configureDesignSheetFittingContent() {
        configureDesignSheet()
        sheetPresentationController?.detents = [.custom { [weak self] context in
            guard let view = self?.view else { return context.maximumDetentValue }
            let fitting = view.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            // 시트 높이에는 아래 안전 영역이 들어가지 않는다.
            return min(fitting.height - view.safeAreaInsets.bottom, context.maximumDetentValue)
        }]
    }
}
