import ActivityKit
import Foundation
import WidgetKit

/// 오늘 요약이 바뀌면 위젯을 다시 그리고 라이브 액티비티를 시작 · 갱신한다.
final class MG2TodaySurfaceRefresher: TodaySurfaceRefreshing {
    func refresh(with snapshot: MG2TodaySnapshot) {
        WidgetCenter.shared.reloadAllTimelines()
        Task { await updateActivity(with: snapshot) }
    }

    private func updateActivity(with snapshot: MG2TodaySnapshot) async {
        let state = MG2TodayActivityAttributes.ContentState(done: snapshot.done, total: snapshot.total, nextTitle: snapshot.next?.title, pose: snapshot.pose, line: snapshot.line)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: snapshot.date)
        let content = ActivityContent(state: state, staleDate: endOfDay)
        let activities = Activity<MG2TodayActivityAttributes>.activities

        // 다른 날 시작한 액티비티는 닫는다.
        for activity in activities where activity.content.staleDate != endOfDay {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        if let current = activities.first(where: { $0.content.staleDate == endOfDay }) {
            await current.update(content)
        } else if snapshot.total > 0, snapshot.done < snapshot.total, ActivityAuthorizationInfo().areActivitiesEnabled {
            _ = try? Activity.request(attributes: MG2TodayActivityAttributes(), content: content)
        }
    }
}
