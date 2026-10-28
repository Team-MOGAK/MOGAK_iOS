import Foundation
import UserNotifications

/// 매일 아침 조각 알림. 권한을 받으면 반복 알림 하나를 건다.
final class MG2ReminderScheduler: ReminderScheduling {
    private static let offeredKey = "MG2ReminderOffered"
    private static let requestID = "MG2DailyReminder"
    // ponytail: 알림 시각 고정(오전 9시). 사용자 설정이 필요하면 마이페이지 푸시 알림 설정에서 받기.
    private static let hour = 9

    var hasOffered: Bool { UserDefaults.standard.bool(forKey: Self.offeredKey) }

    func markOffered() {
        UserDefaults.standard.set(true, forKey: Self.offeredKey)
    }

    func requestAndScheduleDaily() async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) == true else { return false }

        let content = UNMutableNotificationContent()
        content.title = "오늘의 조각"
        content.body = "오늘 조각, 하나씩 시작해 볼까요?"
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: Self.hour), repeats: true)
        try? await center.add(UNNotificationRequest(identifier: Self.requestID, content: content, trigger: trigger))
        return true
    }
}
