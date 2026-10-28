import Foundation

/// 앱 · 위젯 · 라이브 액티비티가 함께 쓰는 오늘의 조각 요약. 앱이 App Group에 저장하고 위젯이 읽는다.
struct MG2TodaySnapshot: Codable, Equatable {
    struct Piece: Codable, Equatable {
        let jogakID: Int
        let scheduledDate: Date
        let title: String
        let mogakTitle: String
        /// 모각 색 RRGGBB. 화면에서 모각 색 팔레트로 바꿔 그린다.
        let color: String?
        let isRoutine: Bool
        var isDone: Bool
    }

    let date: Date
    var pieces: [Piece]
    /// MG2MoakPose.rawValue
    var pose: String
    var line: String

    var done: Int { pieces.filter(\.isDone).count }
    var total: Int { pieces.count }
    var next: Piece? { pieces.first { !$0.isDone } }
}

enum MG2AppGroup {
    static let identifier = "group.com.team.mogaks"
    static let snapshotKey = "MG2TodaySnapshot"
}
