import Foundation

final class DefaultModalartUseCase: ModalartUseCase {

    private let repository: ModalartRepository

    init(repository: ModalartRepository) {
        self.repository = repository
    }

    func getModalartList() async throws -> [MG2ModalartListItemEntity] {
        try await repository.getModalartList()
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        try await repository.getModalartDetail(modalartId: modalartId)
    }

    func getModalartMogakPage(modalartId: Int) async throws -> MG2ModalartMogakPageEntity? {
        try await repository.getModalartMogakPage(modalartId: modalartId)
    }

    func getMogakOccurrences(mogakId: Int, date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        try await repository.getMogakOccurrences(mogakId: mogakId, date: date)
    }

    func getMogakOverview(
        mogakId: Int,
        from date: Date
    ) async throws -> [MG2JogakOccurrenceEntity] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let dates = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: date)
        }

        return try await withThrowingTaskGroup(
            of: [MG2JogakOccurrenceEntity].self
        ) { group in
            for date in dates {
                group.addTask { [repository] in
                    try await repository.getMogakOccurrences(mogakId: mogakId, date: date)
                }
            }

            var occurrenceByJogakID = [Int: MG2JogakOccurrenceEntity]()
            for try await occurrences in group {
                for occurrence in occurrences {
                    let jogakID = occurrence.key.jogakID
                    if let current = occurrenceByJogakID[jogakID],
                       current.key.scheduledDate <= occurrence.key.scheduledDate {
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

    func createModalart(title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        try await repository.createModalart(title: title, color: color)
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
