import SnapKit
import UIKit

/// 세그먼트 (`.md-seg`): 트랙 `segment` · 안쪽 3 · 모서리 12, 옵션 36pt · 13/700.
/// 선택은 `surface` 바탕 · `ink` 글자 · 얕은 그림자, 나머지는 `sub`. 옵션은 2~3개.
final class MG2SegmentedControl: UIControl {
    private(set) var selectedIndex: Int
    private var buttons = [UIButton]()

    init(options: [String], selectedIndex: Int = 0) {
        self.selectedIndex = selectedIndex
        super.init(frame: .zero)
        backgroundColor = DS.Color.segment
        roundCorners(12)

        let stack = UIStackView()
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(3) }

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = T.footnoteBold.font
            button.roundCorners(10)
            button.layer.shadowColor = UIColor(hex: "1E2050").cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 1
            button.addAction(UIAction { [weak self] _ in self?.select(index, sendsActions: true) }, for: .touchUpInside)
            button.snp.makeConstraints { $0.height.equalTo(DS.Size.chip) }
            buttons.append(button)
            stack.addArrangedSubview(button)
        }
        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ index: Int, sendsActions: Bool = false) {
        guard buttons.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
        render()
        if sendsActions { sendActions(for: .valueChanged) }
    }

    private func render() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            button.backgroundColor = isSelected ? DS.Color.surface : .clear
            button.setTitleColor(isSelected ? DS.Color.ink : DS.Color.sub, for: .normal)
            button.layer.shadowOpacity = isSelected ? 0.12 : 0
            button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        }
    }
}
