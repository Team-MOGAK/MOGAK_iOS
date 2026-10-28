import UIKit

enum MG2MandalaGrid {
    static let itemCount = 9
    static let centerIndex = 4

    /// 넓은 화면(Duo 펼침 세로)의 가운데 열 폭. 판과 모든 탭 내용이 이 폭을 넘지 않는다.
    static let maxBoardWidth: CGFloat = 560
    /// 칸 높이가 이보다 낮으면(SE · Duo 접힘) 이름 1줄.
    static let singleLineCellHeight: CGFloat = 124

    /// contentIndex의 반대: 모각 · 조각 순서 → 판 칸 위치.
    static func gridIndex(forContent contentIndex: Int) -> Int {
        contentIndex < centerIndex ? contentIndex : contentIndex + 1
    }

    static func contentIndex(for gridIndex: Int) -> Int? {
        guard gridIndex != centerIndex else { return nil }
        return gridIndex < centerIndex ? gridIndex : gridIndex - 1
    }

    /// 판 칸 크기: 높이 = min(칸 폭 × 1.2, (남은 높이 − 20) / 3), 96–170pt.
    static func boardCellSize(boardWidth: CGFloat, availableHeight: CGFloat) -> CGSize {
        let width = floor((boardWidth - DS.Space.cellGap * 2) / 3)
        let height = floor(min(max(min(width * 1.2, (availableHeight - 20) / 3), 96), 170))
        return CGSize(width: width, height: height)
    }
}
