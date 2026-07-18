import UIKit

enum MG2MandalaGrid {
    static let itemCount = 9
    static let centerIndex = 4
    static let sectionInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    static let minimumLineSpacing: CGFloat = 10
    static let minimumInteritemSpacing: CGFloat = 0

    static func contentIndex(for gridIndex: Int) -> Int? {
        guard gridIndex != centerIndex else { return nil }
        return gridIndex < centerIndex ? gridIndex : gridIndex - 1
    }

    static func itemSize(in collectionView: UICollectionView) -> CGSize {
        CGSize(
            width: collectionView.frame.width / 3 - 10,
            height: collectionView.frame.height / 3 - 10
        )
    }
}
