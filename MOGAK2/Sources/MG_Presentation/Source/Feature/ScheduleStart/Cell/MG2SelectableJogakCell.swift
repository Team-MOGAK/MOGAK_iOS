import UIKit
import SnapKit

/// 조각 가져오기: 고를 수 있는 조각 한 줄. 행 전체가 체크 영역, 이미 오늘의 조각이면 완료 모양으로 잠근다.
final class MG2SelectableJogakCell: UITableViewCell {
    static let reuseIdentifier = "MG2SelectableJogakCell"

    var onSelection: ((Int) -> Void)?

    private var jogakID = 0
    private var isLocked = false

    private let checkView = MG2CheckCircleView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.apply(.callout)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubviews(checkView, titleLabel)

        checkView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(DS.Space.sheet + 8)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.centerY.equalToSuperview()
        }

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewTapped)))
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSelection = nil
        jogakID = 0
        isLocked = false
    }

    func configure(with item: MG2JogakSelectionItem, isSelected: Bool) {
        titleLabel.text = item.title
        jogakID = item.id
        isLocked = !item.isSelectable
        titleLabel.textColor = isLocked ? DS.Color.faint : DS.Color.ink
        accessibilityLabel = item.title + (isLocked ? ", 이미 오늘의 조각" : "")
        setSelectedAppearance(isLocked || isSelected, animated: false)
    }

    func setSelectedAppearance(_ isSelected: Bool) {
        setSelectedAppearance(isSelected, animated: true)
    }

    override func accessibilityActivate() -> Bool {
        contentViewTapped()
        return true
    }

    private func setSelectedAppearance(_ isSelected: Bool, animated: Bool) {
        checkView.setDone(isSelected, color: isLocked ? DS.Color.disabled : DS.Color.accent, animated: animated)
        accessibilityValue = isSelected ? "선택됨" : nil
    }

    @objc private func contentViewTapped() {
        guard !isLocked else { return }
        onSelection?(jogakID)
    }
}
