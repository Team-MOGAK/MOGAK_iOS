import SnapKit
import UIKit

/// 세그먼트 (`.md-seg`). 시스템 UISegmentedControl에 디자인 색만 입힌다.
/// 트랙 `segment`, 선택 칸 `surface` · `ink`, 나머지 `sub`, 글자 13/700. 옵션은 2~3개.
final class MG2SegmentedControl: UISegmentedControl {
    var selectedIndex: Int { selectedSegmentIndex }

    init(options: [String], selectedIndex: Int = 0) {
        super.init(items: options)
        selectedSegmentIndex = selectedIndex
        backgroundColor = DS.Color.segment
        selectedSegmentTintColor = DS.Color.surface
        setTitleTextAttributes([.font: T.footnoteBold.font, .foregroundColor: DS.Color.sub], for: .normal)
        setTitleTextAttributes([.font: T.footnoteBold.font, .foregroundColor: DS.Color.ink], for: .selected)
        // 옵션 높이 36 + 안쪽 3 (`.md-seg`).
        snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.chip + 6) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 코드로 고를 때. 사용자가 누르면 시스템이 `.valueChanged`를 보낸다.
    func select(_ index: Int, sendsActions: Bool = false) {
        guard index != selectedSegmentIndex else { return }
        selectedSegmentIndex = index
        if sendsActions { sendActions(for: .valueChanged) }
    }
}
