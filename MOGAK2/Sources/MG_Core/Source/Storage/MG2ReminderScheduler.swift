import Foundation
import UserNotifications

/// 매일 아침 조각 알림. 권한을 받으면 반복 알림 하나를 건다.
final class MG2ReminderScheduler: ReminderScheduling {
    private static let offeredKey = "MG2ReminderOffered"
    private static let requestID = "MG2DailyReminder"
    private static let timeKey = "MG2ReminderTime"

    var hasOffered: Bool { UserDefaults.standard.bool(forKey: Self.offeredKey) }

    func markOffered() {
        UserDefaults.standard.set(true, forKey: Self.offeredKey)
    }

    var time: DateComponents {
        get {
            let saved = UserDefaults.standard.array(forKey: Self.timeKey) as? [Int] ?? [8, 0]
            return DateComponents(hour: saved.first ?? 8, minute: saved.last ?? 0)
        }
        set { UserDefaults.standard.set([newValue.hour ?? 8, newValue.minute ?? 0], forKey: Self.timeKey) }
    }

    func cancelDaily() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.requestID])
    }

    /// 걸려 있어도 기기 설정에서 알림을 막았으면 오지 않으니 꺼진 것으로 본다.
    func isScheduled() async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard [.authorized, .provisional, .ephemeral].contains(await center.notificationSettings().authorizationStatus) else { return false }
        return await center.pendingNotificationRequests().contains { $0.identifier == Self.requestID }
    }

    func requestAndScheduleDaily() async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) == true else { return false }

        let content = UNMutableNotificationContent()
        content.title = "오늘의 조각"
        content.body = "오늘 조각, 하나씩 시작해 볼까요?"
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        try? await center.add(UNNotificationRequest(identifier: Self.requestID, content: content, trigger: trigger))
        return true
    }
}
