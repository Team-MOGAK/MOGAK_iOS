import Foundation

/// 오늘의 조각 요약을 App Group UserDefaults에 JSON으로 둔다. 위젯 확장이 같은 키로 읽는다.
final class MG2TodaySnapshotStore: TodaySnapshotStorage {
    private let defaults = UserDefaults(suiteName: MG2AppGroup.identifier)

    func load() -> MG2TodaySnapshot? {
        defaults?.data(forKey: MG2AppGroup.snapshotKey).flatMap { try? JSONDecoder().decode(MG2TodaySnapshot.self, from: $0) }
    }

    func save(_ snapshot: MG2TodaySnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: MG2AppGroup.snapshotKey)
    }
}
