import Foundation

/// 오늘의 조각 요약을 App Group에 저장하는 곳. 구현은 MG_Core.
protocol TodaySnapshotStorage {
    func save(_ snapshot: MG2TodaySnapshot)
    func saveNextDay(_ snapshot: MG2TodaySnapshot)
}

/// 위젯 · 라이브 액티비티를 새 요약으로 다시 그린다. 구현은 MG_App (WidgetKit · ActivityKit).
protocol TodaySurfaceRefreshing {
    func refresh(with snapshot: MG2TodaySnapshot)
}

/// 매일 조각 알림. 구현은 MG_Core (UserNotifications).
protocol ReminderScheduling: AnyObject {
    var hasOffered: Bool { get }
    func markOffered()
    /// 매일 알림 시각(시 · 분). 기본 오전 8시.
    var time: DateComponents { get set }
    /// 권한을 받고 `time`에 매일 알림을 건다. 권한이 없으면 false.
    func requestAndScheduleDaily() async -> Bool
    func cancelDaily()
    func isScheduled() async -> Bool
}

/// 광고 노출 규칙에 필요한 기록. 구현은 MG_Core.
protocol AdPolicyStorage: AnyObject {
    var installDate: Date? { get set }
    var interstitialDates: [Date] { get set }
    var lastAppOpenAdDate: Date? { get set }
    var lastBackgroundDate: Date? { get set }
    var unlockedPastDays: [Date] { get set }
}
