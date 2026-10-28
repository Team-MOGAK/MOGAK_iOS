import Combine
import Foundation

/// 오늘의 조각 진척 · 모각이 상태를 만들고 위젯 · 라이브 액티비티 · 알림까지 맞춘다.
final class TodayUseCase {
    private let repository: ScheduleStartRepository
    private let snapshotStorage: TodaySnapshotStorage
    private let surfaces: TodaySurfaceRefreshing
    private let reminder: ReminderScheduling
    private let calendar: Calendar
    private let now: () -> Date
    private var missedYesterdayCache: (day: Date, missed: Bool)?

    /// 앱 밖(위젯 · 라이브 액티비티 버튼)에서 조각이 바뀌면 알린다. 홈은 이걸 듣고 다시 불러온다.
    let externalChanges = PassthroughSubject<Void, Never>()

    init(repository: ScheduleStartRepository, snapshotStorage: TodaySnapshotStorage, surfaces: TodaySurfaceRefreshing, reminder: ReminderScheduling, calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.snapshotStorage = snapshotStorage
        self.surfaces = surfaces
        self.reminder = reminder
        self.calendar = calendar
        self.now = now
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: now())
    }

    /// 오늘 조각으로 요약을 만들어 저장하고 위젯 · 라이브 액티비티를 다시 그린다.
    @discardableResult
    func publish(_ pieces: [MG2TodaySnapshot.Piece]) async -> MG2TodaySnapshot {
        let missed = await missedYesterday()
        let done = pieces.filter(\.isDone).count
        let mood = MG2Mood(done: done, total: pieces.count, isEvening: calendar.component(.hour, from: now()) >= MG2Mood.eveningHour, missedYesterday: missed)
        let snapshot = MG2TodaySnapshot(date: calendar.startOfDay(for: now()), pieces: pieces, pose: mood.pose(done: done, total: pieces.count).rawValue, line: mood.line(done: done, total: pieces.count))
        snapshotStorage.save(snapshot)
        surfaces.refresh(with: snapshot)
        return snapshot
    }

    /// 라이브 액티비티 "다음 조각 완료".
    func completeNextPiece() async throws {
        var pieces = try await todayPieces()
        guard let index = pieces.firstIndex(where: { !$0.isDone }) else { return }
        try await setCompletion(&pieces, at: index, isDone: true)
    }

    /// 위젯 체크.
    func togglePiece(jogakID: Int) async throws {
        var pieces = try await todayPieces()
        guard let index = pieces.firstIndex(where: { $0.jogakID == jogakID }) else { return }
        try await setCompletion(&pieces, at: index, isDone: !pieces[index].isDone)
    }

    var shouldOfferReminder: Bool { !reminder.hasOffered }

    func enableReminder() async -> Bool {
        reminder.markOffered()
        return await reminder.requestAndScheduleDaily()
    }

    func declineReminder() {
        reminder.markOffered()
    }

    static func piece(from entity: MG2JogakOccurrenceEntity) -> MG2TodaySnapshot.Piece {
        MG2TodaySnapshot.Piece(jogakID: entity.key.jogakID, scheduledDate: entity.key.scheduledDate, title: entity.title, mogakTitle: entity.mogakTitle, color: entity.color, isRoutine: entity.isRoutine, isDone: entity.status == .success)
    }

    private func todayPieces() async throws -> [MG2TodaySnapshot.Piece] {
        try await repository.getJogakOccurrences(date: now()).map(Self.piece(from:))
    }

    private func setCompletion(_ pieces: inout [MG2TodaySnapshot.Piece], at index: Int, isDone: Bool) async throws {
        let key = MG2JogakOccurrenceKey(jogakID: pieces[index].jogakID, scheduledDate: pieces[index].scheduledDate)
        if isDone {
            try await repository.markJogakSucceeded(key: key)
        } else {
            try await repository.markJogakFailed(key: key)
        }
        pieces[index].isDone = isDone
        await publish(pieces)
        externalChanges.send()
    }

    /// 어제 조각이 있었는데 하나도 못 했으면 true. 하루에 한 번만 불러온다.
    private func missedYesterday() async -> Bool {
        let today = calendar.startOfDay(for: now())
        if let cache = missedYesterdayCache, cache.day == today { return cache.missed }
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let occurrences = try? await repository.getJogakOccurrences(date: yesterday) else { return false }
        let missed = !occurrences.isEmpty && !occurrences.contains { $0.status == .success }
        missedYesterdayCache = (today, missed)
        return missed
    }
}
