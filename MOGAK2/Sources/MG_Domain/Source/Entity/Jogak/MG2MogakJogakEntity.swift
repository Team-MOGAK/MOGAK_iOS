import Foundation

/// 모각의 조각 하나. 날짜와 상관없이 지난 조각 · 앞으로 예정된 조각까지 모두 온다.
struct MG2MogakJogakEntity {
    let jogakID: Int
    let title: String
    let isRoutine: Bool
    let days: [MG2Weekday]
}
