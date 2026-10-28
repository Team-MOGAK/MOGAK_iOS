import UIKit
import SnapKit

/// 조각 가져오기: 모다라트 고르기 한 줄 (리스트 타일 56). 판 색 점 · 이름 · 셰브론(`ghost`).
final class MG2ModalartOptionCell: UITableViewCell {
    static let reuseIdentifier = "MG2ModalartOptionCell"

    private let tileView = UIView()
    private let dotView = UIView()
    private let modalartLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        tileView.backgroundColor = DS.Color.listTile
        tileView.roundCorners(DS.Radius.field)
        dotView.layer.cornerRadius = 5
        modalartLabel.apply(.row)
        chevronView.tintColor = DS.Color.ghost
        contentView.addSubview(tileView)
        tileView.addSubviews(dotView, modalartLabel, chevronView)

        tileView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.greaterThanOrEqualTo(DS.Size.row)
        }
        dotView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(10)
        }
        modalartLabel.snp.makeConstraints {
            $0.leading.equalTo(dotView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronView.snp.leading).offset(-8)
        }
        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with modalart: MG2ModalartOption) {
        modalartLabel.text = modalart.title
        dotView.backgroundColor = modalart.color.isEmpty ? DS.Color.accent : DS.Moak.displayColor(forServerHex: modalart.color)
        accessibilityLabel = "‘\(modalart.title)’ 모다라트"
    }
}
