import Foundation

final class ModalartUseCase {
    /// 제목을 정하기 전 기본 모다라트의 색
    private static let defaultModalartColor = "BFC3D4"

    private let repository: ModalartRepository
    /// 조각 상세 API는 조각 저장소에 있다.
    private let jogakRepository: ScheduleStartRepository

    init(repository: ModalartRepository, jogakRepository: ScheduleStartRepository) {
        self.repository = repository
        self.jogakRepository = jogakRepository
    }

    /// 모다라트 목록. 하나도 없으면 기본 모다라트를 만들어 돌려준다.
    func loadModalarts() async throws -> [MG2ModalartListItemEntity] {
        let modalarts = try await repository.getModalartList()
        guard modalarts.isEmpty else { return modalarts }
        return [try await createDefaultModalart(existing: [])]
    }

    /// "내 모다라트N" 제목으로 새 모다라트를 만든다. N은 이미 쓴 번호 다음.
    func createDefaultModalart(existing: [MG2ModalartListItemEntity]) async throws -> MG2ModalartListItemEntity {
        let created = try await repository.createModalart(title: MG2ModalartDefaultTitle.next(after: existing.map(\.title)), color: Self.defaultModalartColor)
        return MG2ModalartListItemEntity(id: created.id, title: created.title, color: created.color)
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        try await repository.getModalartDetail(modalartId: modalartId)
    }

    func getModalartMogaks(modalartId: Int) async throws -> [MG2ModalartMogakItemEntity] {
        try await repository.getModalartMogaks(modalartId: modalartId)
    }

    /// 오늘부터 7일 동안의 조각을 모아, 조각마다 가장 가까운 날짜 하나만 남긴다.
    func getMogakOverview(mogakId: Int, from date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let dates = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: date)
        }

        return try await withThrowingTaskGroup(of: [MG2JogakOccurrenceEntity].self) { group in
            for date in dates {
                group.addTask { [repository] in try await repository.getMogakOccurrences(mogakId: mogakId, date: date) }
            }

            var occurrenceByJogakID = [Int: MG2JogakOccurrenceEntity]()
            for try await occurrences in group {
                for occurrence in occurrences {
                    let jogakID = occurrence.key.jogakID
                    if let current = occurrenceByJogakID[jogakID], current.key.scheduledDate <= occurrence.key.scheduledDate {
                        continue
                    }
                    occurrenceByJogakID[jogakID] = occurrence
                }
            }
            return occurrenceByJogakID.values.sorted {
                $0.key.jogakID < $1.key.jogakID
            }
        }
    }

    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity {
        try await jogakRepository.getJogakDetail(jogakId: jogakId)
    }

    /// 루틴 조각의 반복 요일. 조각마다 상세 API를 불러야 해서 하나씩 요청한다.
    func routineWeekdays(for occurrences: [MG2JogakOccurrenceEntity]) async throws -> [Int: [MG2Weekday]] {
        var weekdaysByJogakID = [Int: [MG2Weekday]]()
        for occurrence in occurrences where occurrence.isRoutine {
            let jogakID = occurrence.key.jogakID
            weekdaysByJogakID[jogakID] = try await jogakRepository.getJogakDetail(jogakId: jogakID).days
        }
        return weekdaysByJogakID
    }

    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        try await repository.editModalart(id: id, title: title, color: color)
    }

    func deleteModalart(id: Int) async throws {
        try await repository.deleteModalart(id: id)
    }

    func deleteMogak(mogakId: Int) async throws {
        try await repository.deleteMogak(mogakId: mogakId)
    }

    func deleteJogak(jogakId: Int) async throws {
        try await repository.deleteJogak(jogakId: jogakId)
    }
}
