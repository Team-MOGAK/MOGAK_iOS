import SnapKit
import UIKit

/// 처음 모두 완료한 날 한 번만 보여주는 알림 권유 시트. `.md-sheet` padding 16 / 20 / 20. 높이는 내용에 맞춘다.
final class MG2ReminderOfferModal: UIViewController {
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let mascot = MG2MascotView(size: 88)
        mascot.pose = .wink
        mascot.isInteractive = false
        let titleLabel = UILabel()
        titleLabel.apply(.headline)
        titleLabel.text = "내일도 잊지 않게 알려드릴까요?"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        let subLabel = UILabel()
        subLabel.apply(.footnote, color: DS.Color.sub)
        subLabel.text = "매일 아침 오늘의 조각을 알려드려요"
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0

        let acceptButton = MG2PrimaryActionButton()
        acceptButton.setTitle("알림 받기", for: .normal)
        acceptButton.addAction(UIAction { [weak self] _ in self?.onAccept?() }, for: .touchUpInside)
        let declineButton = MG2PrimaryActionButton(style: .ghost)
        declineButton.setTitle("나중에 할게요", for: .normal)
        declineButton.addAction(UIAction { [weak self] _ in self?.onDecline?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mascot, titleLabel, subLabel, acceptButton, declineButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.setCustomSpacing(20, after: subLabel)
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.sheet).priority(.high)
        }
        // 버튼 높이는 스타일 기본값(primary 52 · ghost 44).
        [acceptButton, declineButton].forEach { button in button.snp.makeConstraints { $0.width.equalTo(stack) } }
    }
}
