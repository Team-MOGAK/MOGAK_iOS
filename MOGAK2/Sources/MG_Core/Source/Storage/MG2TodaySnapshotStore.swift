import Foundation

/// 오늘의 조각 요약을 App Group UserDefaults에 JSON으로 둔다. 위젯 확장이 같은 키로 읽는다.
final class MG2TodaySnapshotStore: TodaySnapshotStorage {
    private let defaults = UserDefaults(suiteName: MG2AppGroup.identifier)

    func save(_ snapshot: MG2TodaySnapshot) {
        save(snapshot, forKey: MG2AppGroup.snapshotKey)
    }

    func saveNextDay(_ snapshot: MG2TodaySnapshot) {
        save(snapshot, forKey: MG2AppGroup.nextDaySnapshotKey)
    }

    func clear() {
        defaults?.removeObject(forKey: MG2AppGroup.snapshotKey)
        defaults?.removeObject(forKey: MG2AppGroup.nextDaySnapshotKey)
    }

    private func save(_ snapshot: MG2TodaySnapshot, forKey key: String) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
    }
}
