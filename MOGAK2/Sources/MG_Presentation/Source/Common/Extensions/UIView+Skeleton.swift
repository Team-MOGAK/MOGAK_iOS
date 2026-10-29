import SkeletonView
import UIKit

/// 칸 안에 카드가 따로 있는 셀. 칸 사이 여백까지 덮지 않게 그 카드를 덩어리로 알려 준다.
protocol MG2SkeletonBlockCell: UIView {
    var skeletonBlock: UIView { get }
}

/// 스켈레톤은 SkeletonView 라이브러리가 그린다.
/// API에서 오는 내용 자리를 글자 하나하나가 아니라 칸 · 카드 · 글 상자 하나씩 통째로 덮는다. API와 상관없는 뷰에는 부르지 않는다.
/// 순서: 화면 전환 동안은 제자리에 멈춘 덩어리 → 전환이 끝나면 반짝임 → 데이터가 오면(전환이 끝난 뒤, `afterTransition`) 내용으로 겹쳐 바뀐다.
extension UIView {
    /// 반짝이지 않는 한 가지 색. 전환 중에는 이것만 보인다.
    private static let restingGradient = SkeletonGradient(baseColor: DS.Color.segment, secondaryColor: DS.Color.segment)
    private static let shimmerGradient = SkeletonGradient(baseColor: DS.Color.segment)
    /// 덩어리 크기 · 위치가 바뀌면 바로 따라간다. 기본값이면 0.25초 동안 혼자 늘어나 화면 전환과 겹쳐 보인다.
    private static let followsLayoutImmediately: [String: CAAction] = ["bounds": NSNull(), "position": NSNull(), "frame": NSNull()]

    /// 덩어리로 덮는다. 표 · 컬렉션이면 보이는 칸마다 한 덩어리이고, `isIncluded`로 덮지 않을 칸(이미 아는 내용)을 뺀다.
    /// 데이터가 다 올 때까지 그대로 두고, 오면 `hideSkeletonBlocks()` 뒤에 내용을 그린다.
    func showSkeletonBlocks(where isIncluded: (IndexPath) -> Bool = { _ in true }) {
        accessibilityElementsHidden = true
        // 글 상자도 한 덩어리로 (라이브러리 기본은 글줄 막대).
        SkeletonAppearance.default.renderSingleLineAsView = true
        let newBlocks = skeletonBlocks(where: isIncluded).filter { !$0.sk.isSkeletonActive }
        for block in newBlocks {
            block.isSkeletonable = true
            (block as? UILabel)?.skeletonTextNumberOfLines = 1
            block.skeletonCornerRadius = Float(block.layer.cornerRadius)
            // 페이드 없이 화면의 한 부분으로 바로 보인다 (라이브러리 기본은 0.25초 페이드).
            block.showGradientSkeleton(usingGradient: Self.restingGradient, transition: .none)
            block.layer.sublayers?.last?.actions = Self.followsLayoutImmediately
        }
        // 라이브러리가 덮기 전 누르기 상태를 저장했다가 걷을 때 되돌린다. 먼저 끄면 꺼진 채로 저장돼 영영 못 누른다.
        isUserInteractionEnabled = false
        guard !newBlocks.isEmpty, !UIAccessibility.isReduceMotionEnabled else { return }
        // 반짝임은 화면 전환이 끝난 뒤에. 전환은 이 다음 차례에 시작되므로 한 번 미뤄서 본다.
        DispatchQueue.main.async { [weak self] in
            let start = { newBlocks.filter(\.sk.isSkeletonActive).forEach { $0.updateAnimatedGradientSkeleton(usingGradient: Self.shimmerGradient) } }
            guard let viewController = self?.owningViewController else { return start() }
            viewController.afterTransition(start)
        }
    }

    func hideSkeletonBlocks() {
        isUserInteractionEnabled = true
        accessibilityElementsHidden = false
        skeletonBlocks(where: { _ in true }).forEach { $0.hideSkeleton(reloadDataAfter: false, transition: .none) }
    }

    private func skeletonBlocks(where isIncluded: (IndexPath) -> Bool) -> [UIView] {
        if let tableView = self as? UITableView {
            return (tableView.indexPathsForVisibleRows ?? []).filter(isIncluded).compactMap { tableView.cellForRow(at: $0).map(\.skeletonTarget) }
        }
        if let collectionView = self as? UICollectionView {
            return collectionView.indexPathsForVisibleItems.filter(isIncluded).compactMap { collectionView.cellForItem(at: $0).map(\.skeletonTarget) }
        }
        return [self]
    }
}

private extension UIView {
    var owningViewController: UIViewController? {
        var responder: UIResponder? = next
        while let current = responder {
            if let viewController = current as? UIViewController { return viewController }
            responder = current.next
        }
        return nil
    }

    /// 덮을 덩어리. 이름을 프로토콜의 `skeletonBlock`과 같게 두면 아래 줄이 프로토콜 대신 이 속성을 다시 불러 끝없이 돌다 터진다.
    var skeletonTarget: UIView {
        (self as? MG2SkeletonBlockCell)?.skeletonBlock ?? (self as? UITableViewCell)?.contentView ?? (self as? UICollectionViewCell)?.contentView ?? self
    }
}
