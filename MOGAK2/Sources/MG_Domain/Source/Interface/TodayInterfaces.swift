import Foundation

/// 오늘의 조각 요약을 App Group에 저장하는 곳. 구현은 MG_Core.
protocol TodaySnapshotStorage {
    func load() -> MG2TodaySnapshot?
    func save(_ snapshot: MG2TodaySnapshot)
}

/// 위젯 · 라이브 액티비티를 새 요약으로 다시 그린다. 구현은 MG_App (WidgetKit · ActivityKit).
protocol TodaySurfaceRefreshing {
    func refresh(with snapshot: MG2TodaySnapshot)
}

/// 매일 조각 알림. 구현은 MG_Core (UserNotifications).
protocol ReminderScheduling {
    var hasOffered: Bool { get }
    func markOffered()
    func requestAndScheduleDaily() async -> Bool
}

/// 광고 노출 규칙에 필요한 기록. 구현은 MG_Core.
protocol AdPolicyStorage: AnyObject {
    var installDate: Date? { get set }
    var interstitialDates: [Date] { get set }
    var lastAppOpenAdDate: Date? { get set }
    var lastBackgroundDate: Date? { get set }
}
