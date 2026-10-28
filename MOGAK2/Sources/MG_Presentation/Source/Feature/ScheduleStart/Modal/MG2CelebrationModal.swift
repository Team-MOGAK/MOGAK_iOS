import SnapKit
import UIKit

/// 오늘 마지막 조각을 체크한 순간의 축하 카드. 카드 안에는 광고를 넣지 않는다.
final class MG2CelebrationModal: UIViewController {
    var onConfirm: (() -> Void)?

    private let done: Int
    private let completedCount: Int
    private let mascot = MG2MascotView(size: 104)
    private let titleLabel = UILabel()

    init(done: Int, completedCount: Int) {
        self.done = done
        self.completedCount = completedCount
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.scrim

        let card = UIView()
        card.backgroundColor = DS.Color.surface
        card.roundCorners(28)
        card.accessibilityViewIsModal = true

        mascot.pose = .proud
        mascot.isInteractive = false
        // `.md-cele h3` 22/28 800 · `p` 14/21 500 sub. 큰 글자에서는 줄바꿈.
        titleLabel.font = .scaledCapped(.pretendard(.extraBold, size: 22), relativeTo: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = DS.Color.ink
        titleLabel.text = "오늘 조각 모두 완료!"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header
        let subLabel = UILabel()
        subLabel.apply(.paragraph, color: DS.Color.sub)
        subLabel.font = .scaledCapped(.pretendard(.medium, size: 14), relativeTo: .subheadline)
        subLabel.text = "모다라트가 오늘 몫만큼 채워졌어요"
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0

        // TODO(server): 이번 주 % 통계는 주간 진척 API가 생기면 추가.
        let stats = UIStackView(arrangedSubviews: [stat(value: "\(done)/\(done)", label: "오늘"), stat(value: "\(completedCount)회", label: "완료한 조각")])
        stats.distribution = .fillEqually
        stats.backgroundColor = DS.Color.listTile
        stats.roundCorners(16)
        stats.isLayoutMarginsRelativeArrangement = true
        stats.layoutMargins = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)

        let confirmButton = MG2PrimaryActionButton()
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.addAction(UIAction { [weak self] _ in self?.onConfirm?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mascot, titleLabel, subLabel, stats, confirmButton])
        stack.axis = .vertical
        stack.alignment = .center
        // gap 10, 통계 위아래 margin 8 · 6
        stack.spacing = 10
        stack.setCustomSpacing(18, after: subLabel)
        stack.setCustomSpacing(16, after: stats)

        view.addSubview(card)
        card.addSubview(stack)
        card.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter * 2).priority(.high)
            $0.width.lessThanOrEqualTo(340)
        }
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 22, bottom: 20, right: 22)) }
        [stats, confirmButton].forEach { view in view.snp.makeConstraints { $0.width.equalTo(stack) } }
    }

    /// 나타날 때 모각이가 한 번 폴짝(`hop: 1`). 동작 줄이기면 MG2MascotView가 건너뛴다.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mascot.hop()
        UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
    }

    private func stat(value: String, label: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.font = .scaledCapped(UIFont.pretendard(.extraBold, size: 18).withMonospacedDigits(), relativeTo: .headline)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = DS.Color.ink
        valueLabel.text = value
        let nameLabel = UILabel()
        nameLabel.apply(.caption2, color: DS.Color.muted)
        nameLabel.text = label
        let stack = UIStackView(arrangedSubviews: [valueLabel, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }
}
