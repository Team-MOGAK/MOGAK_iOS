import ActivityKit
import Foundation
import WidgetKit

/// 오늘 요약이 바뀌면 위젯을 다시 그리고 라이브 액티비티를 시작 · 갱신 · 종료한다.
final class MG2TodaySurfaceRefresher: TodaySurfaceRefreshing {
    private let lock = NSLock()
    /// 라이브 액티비티 반영은 들어온 순서대로 하나씩. 겹치면 예전 숫자가 나중에 반영되거나 액티비티가 두 개 생긴다.
    private var lastUpdate: Task<Void, Never>?

    func refresh(with snapshot: MG2TodaySnapshot) {
        WidgetCenter.shared.reloadAllTimelines()
        enqueue { await Self.updateActivity(with: snapshot) }
    }

    func clear() {
        WidgetCenter.shared.reloadAllTimelines()
        enqueue {
            for activity in Activity<MG2TodayActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func enqueue(_ work: @escaping () async -> Void) {
        lock.lock()
        defer { lock.unlock() }
        let previous = lastUpdate
        lastUpdate = Task {
            await previous?.value
            await work()
        }
    }

    private static func updateActivity(with snapshot: MG2TodaySnapshot) async {
        let state = MG2TodayActivityAttributes.ContentState(done: snapshot.done, total: snapshot.total, nextTitle: snapshot.next?.title, pose: snapshot.pose, line: snapshot.line)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: snapshot.date)
        let content = ActivityContent(state: state, staleDate: endOfDay)

        // 다른 날 시작한 액티비티는 닫는다. 오늘 조각이 하나도 없어졌으면 오늘 것도 닫는다.
        for activity in Activity<MG2TodayActivityAttributes>.activities where activity.content.staleDate != endOfDay || snapshot.total == 0 {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        guard snapshot.total > 0 else { return }

        if let current = Activity<MG2TodayActivityAttributes>.activities.first(where: { $0.content.staleDate == endOfDay }) {
            await current.update(content)
        } else if snapshot.done < snapshot.total, ActivityAuthorizationInfo().areActivitiesEnabled {
            _ = try? Activity.request(attributes: MG2TodayActivityAttributes(), content: content)
        }
    }
}
