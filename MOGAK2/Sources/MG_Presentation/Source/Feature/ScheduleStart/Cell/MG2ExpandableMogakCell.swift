import Then
import UIKit
import SnapKit

/// 조각 가져오기: 모각 머리 줄. 모각 색 태그 · 펼침 셰브론.
final class MG2ExpandableMogakCell: UITableViewCell, MG2SkeletonBlockCell {
    static let reuseIdentifier = "MG2ExpandableMogakCell"

    private let tagLabel = MG2TagLabel()
    private let chevronImageView = UIImageView()
    /// 줄 하나를 스켈레톤 한 덩어리로. 위아래 4씩 띄워 줄마다 따로 보이게 한다.
    private let rowView = UIView().then { $0.roundCorners(DS.Radius.field) }
    var skeletonBlock: UIView { rowView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        chevronImageView.tintColor = DS.Color.ghost
        chevronImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        // 긴 모각 이름은 태그 안에서 말줄임.
        tagLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        contentView.addSubview(rowView)
        rowView.addSubviews(tagLabel, chevronImageView)

        // 최소 56, 큰 글자에서는 늘어난다. contentView는 SnapKit을 쓰면 오토리사이징이 꺼지므로 앵커로.
        let minimumHeight = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: DS.Size.row)
        minimumHeight.priority = UILayoutPriority(999)
        minimumHeight.isActive = true
        rowView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        tagLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().inset(8)
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-12)
        }
        chevronImageView.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
        }
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setExpanded(_ isExpanded: Bool) {
        chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold))
        accessibilityValue = isExpanded ? "펼침" : "접힘"
    }

    func configure(with section: MG2MogakJogakSection) {
        tagLabel.configure(text: section.title, moak: DS.Moak.from(hex: section.color.isEmpty ? nil : section.color))
        accessibilityLabel = "\(section.title) 모각"
    }
}
