import SnapKit
import UIKit

/// 떠 있는 탭 바 (`.md-tabbar`): 64pt 캡슐, 흰 92% + 블러, 안쪽 여백 4.
/// 선택은 `tab-active` 캡슐 · `accent-deep`, 나머지는 `ink`. 아이콘 22, 라벨 11/700.
final class MG2FloatingTabBar: UIView {
    struct Item {
        let index: Int
        let title: String
        let symbol: String
    }

    var onSelect: ((Int) -> Void)?

    private let items: [Item]
    private var buttons = [UIButton]()

    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
        layer.apply(.tabBar)

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blurView.layer.cornerRadius = DS.Size.tabBar / 2
        blurView.clipsToBounds = true
        blurView.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let stack = UIStackView()
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }

        for item in items {
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage(systemName: item.symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            configuration.imagePlacement = .top
            configuration.imagePadding = 1
            configuration.background.cornerRadius = (DS.Size.tabBar - 8) / 2
            configuration.contentInsets = .zero
            configuration.attributedTitle = AttributedString(item.title, attributes: AttributeContainer([.font: T.caption2.font]))
            let button = UIButton(configuration: configuration)
            button.accessibilityLabel = item.title
            button.addAction(UIAction { [weak self] _ in self?.onSelect?(item.index) }, for: .touchUpInside)
            button.enablePressFeedback()
            buttons.append(button)
            stack.addArrangedSubview(button)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ index: Int) {
        for (item, button) in zip(items, buttons) {
            let isSelected = item.index == index
            button.configuration?.baseForegroundColor = isSelected ? DS.Color.accentDeep : DS.Color.ink
            button.configuration?.background.backgroundColor = isSelected ? DS.Color.tabActive : .clear
            button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        }
    }
}
