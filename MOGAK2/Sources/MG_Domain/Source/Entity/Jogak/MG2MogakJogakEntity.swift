import Foundation

/// 모각의 조각 하나. 날짜와 상관없이 지난 조각 · 앞으로 예정된 조각까지 모두 온다.
struct MG2MogakJogakEntity {
    let jogakID: Int
    let title: String
    let isRoutine: Bool
    let days: [MG2Weekday]
    let startDate: Date
    let endDate: Date?

    /// 끝나지 않은 조각인지. 서버가 모각당 8개 제한을 셀 때와 같은 기준이다 (일회성의 endDate는 늘 nil).
    /// today는 그날 0시.
    func isCurrentOrFuture(on today: Date) -> Bool {
        isRoutine ? (endDate ?? today) >= today : startDate >= today
    }
}
