import SkeletonView
import UIKit

/// 칸 안에 카드가 따로 있는 셀. 칸 사이 여백까지 덮지 않게 그 카드를 덩어리로 알려 준다.
protocol MG2SkeletonBlockCell: UIView {
    var skeletonBlock: UIView { get }
}

/// 스켈레톤은 SkeletonView 라이브러리가 그린다.
/// API에서 오는 내용 자리를 글자 하나하나가 아니라 칸 · 카드 · 글 상자 하나씩 통째로 덮는다. API와 상관없는 뷰에는 부르지 않는다.
extension UIView {
    /// 덩어리로 덮는다. 표 · 컬렉션이면 보이는 칸마다 한 덩어리이고, `isIncluded`로 덮지 않을 칸(이미 아는 내용)을 뺀다.
    /// 데이터가 다 올 때까지 그대로 두고, 오면 `hideSkeletonBlocks()` 뒤에 내용을 그린다.
    func showSkeletonBlocks(where isIncluded: (IndexPath) -> Bool = { _ in true }) {
        accessibilityElementsHidden = true
        // 글 상자도 한 덩어리로 (라이브러리 기본은 글줄 막대).
        SkeletonAppearance.default.renderSingleLineAsView = true
        for block in skeletonBlocks(where: isIncluded) {
            block.isSkeletonable = true
            (block as? UILabel)?.skeletonTextNumberOfLines = 1
            block.skeletonCornerRadius = Float(block.layer.cornerRadius)
            if UIAccessibility.isReduceMotionEnabled {
                block.showSkeleton(usingColor: DS.Color.segment)
            } else {
                block.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: DS.Color.segment))
            }
        }
        // 라이브러리가 덮기 전 누르기 상태를 저장했다가 걷을 때 되돌린다. 먼저 끄면 꺼진 채로 저장돼 영영 못 누른다.
        isUserInteractionEnabled = false
    }

    func hideSkeletonBlocks() {
        isUserInteractionEnabled = true
        accessibilityElementsHidden = false
        skeletonBlocks(where: { _ in true }).forEach { $0.hideSkeleton(reloadDataAfter: false, transition: .none) }
    }

    private func skeletonBlocks(where isIncluded: (IndexPath) -> Bool) -> [UIView] {
        if let tableView = self as? UITableView {
            return (tableView.indexPathsForVisibleRows ?? []).filter(isIncluded).compactMap { tableView.cellForRow(at: $0).map(\.skeletonBlock) }
        }
        if let collectionView = self as? UICollectionView {
            return collectionView.indexPathsForVisibleItems.filter(isIncluded).compactMap { collectionView.cellForItem(at: $0).map(\.skeletonBlock) }
        }
        return [self]
    }
}

private extension UIView {
    var skeletonBlock: UIView {
        (self as? MG2SkeletonBlockCell)?.skeletonBlock ?? (self as? UITableViewCell)?.contentView ?? (self as? UICollectionViewCell)?.contentView ?? self
    }
}
