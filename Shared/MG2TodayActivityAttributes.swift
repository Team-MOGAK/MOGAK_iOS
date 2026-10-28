import ActivityKit
import Foundation

/// 오늘의 조각 라이브 액티비티. 앱이 시작 · 갱신하고 위젯 확장이 그린다.
struct MG2TodayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var done: Int
        var total: Int
        var nextTitle: String?
        /// MG2MoakPose.rawValue
        var pose: String
        var line: String
    }
}
