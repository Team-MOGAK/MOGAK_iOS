import UIKit

final class MG2LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?
            .compactMap({ $0.copy() as? UICollectionViewLayoutAttributes }) else {
            return nil
        }

        var leftMargin = sectionInset.left
        var previousMaxY: CGFloat = -1

        for attribute in attributes where attribute.representedElementCategory == .cell {
            if attribute.frame.minY >= previousMaxY {
                leftMargin = sectionInset.left
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing
            previousMaxY = max(attribute.frame.maxY, previousMaxY)
        }

        return attributes
    }
}
