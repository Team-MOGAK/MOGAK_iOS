import UIKit
import SnapKit

/// 조각 가져오기: 모각 머리 줄. 모각 색 태그 · 펼침 셰브론.
final class MG2ExpandableMogakCell: UITableViewCell {
    static let reuseIdentifier = "MG2ExpandableMogakCell"

    private let tagLabel = MG2TagLabel()
    private let chevronImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        chevronImageView.tintColor = DS.Color.ghost
        contentView.addSubviews(tagLabel, chevronImageView)

        tagLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(DS.Space.sheet)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-12)
        }
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(DS.Space.sheet)
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
