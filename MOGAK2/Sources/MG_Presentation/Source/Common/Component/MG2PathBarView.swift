import UIKit

/// 경로의 한 칸. colorHex가 있으면 그 모각 색 태그, 없으면 회색 칩.
struct MG2PathItem {
    let label: String
    var colorHex: String?
}

/// 만들기 화면 위 경로 (`.md-path`): 판 › 모각 › 조각 n/8. 지금 무엇을 만들고 있는지 알려 준다.
final class MG2PathBarView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .center
        spacing = 6
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ items: [MG2PathItem]) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in items.enumerated() {
            if index > 0 { addArrangedSubview(makeSeparator()) }
            // 자리가 모자라면 앞(판 이름)부터 줄인다. 마지막(지금 만드는 것)이 가장 오래 남는다.
            let label = makeLabel(for: item)
            label.setContentCompressionResistancePriority(.defaultLow + Float(index), for: .horizontal)
            addArrangedSubview(label)
        }
        isHidden = items.isEmpty
        accessibilityLabel = "경로, " + items.map(\.label).joined(separator: ", ")
    }

    private func makeLabel(for item: MG2PathItem) -> UILabel {
        guard let colorHex = item.colorHex else {
            let chip = MG2PaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
            chip.apply(.caption1, color: DS.Color.ink3)
            chip.text = item.label
            chip.backgroundColor = DS.Color.segment
            chip.roundCorners(DS.Radius.tag)
            chip.clipsToBounds = true
            chip.lineBreakMode = .byTruncatingTail
            return chip
        }
        let tag = MG2TagLabel()
        tag.configure(text: item.label, moak: DS.Moak.from(hex: colorHex))
        return tag
    }

    /// 구분 화살표는 장식이라 `ghost`.
    private func makeSeparator() -> UILabel {
        let separator = UILabel()
        separator.text = "›"
        separator.font = .scaledCapped(.pretendard(.extraBold, size: 10), relativeTo: .caption2)
        separator.adjustsFontForContentSizeCategory = true
        separator.textColor = DS.Color.ghost
        separator.setContentCompressionResistancePriority(.required, for: .horizontal)
        return separator
    }
}
