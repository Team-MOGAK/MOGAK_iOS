import Foundation

/// 한 판의 이번 주(일~토) 진척. 앞으로 올 회차도 예정 수에 들어간다.
struct MG2WeeklyProgress: Equatable {
    struct Mogak: Equatable {
        let mogakID: Int
        let percent: Int
        let plannedCount: Int
    }

    let percent: Int
    let doneCount: Int
    let plannedCount: Int
    let mogaks: [Mogak]

    /// 여러 판을 합친 %. 이번 주 회차가 하나도 없으면 nil.
    static func combinedPercent(_ boards: [MG2WeeklyProgress]) -> Int? {
        let planned = boards.reduce(0) { $0 + $1.plannedCount }
        guard planned > 0 else { return nil }
        return Int((Double(boards.reduce(0) { $0 + $1.doneCount }) / Double(planned) * 100).rounded())
    }
}
