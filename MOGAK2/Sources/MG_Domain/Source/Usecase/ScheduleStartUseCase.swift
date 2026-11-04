import Foundation

final class ScheduleStartUseCase {
    private let repository: ScheduleStartRepository
    private let modalartRepository: ModalartRepository

    init(repository: ScheduleStartRepository, modalartRepository: ModalartRepository) {
        self.repository = repository
        self.modalartRepository = modalartRepository
    }

    func getJogakOccurrences(date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        try await repository.getJogakOccurrences(date: date)
    }

    func startJogak(jogakId: Int, scheduledDate: Date) async throws {
        try await repository.startJogak(jogakId: jogakId, scheduledDate: scheduledDate)
    }

    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity {
        try await repository.getJogakDetail(jogakId: jogakId)
    }

    func setJogakCompletion(key: MG2JogakOccurrenceKey, isCompleted: Bool) async throws {
        if isCompleted {
            try await repository.markJogakSucceeded(key: key)
        } else {
            try await repository.markJogakFailed(key: key)
        }
    }

    func getModalartList() async throws -> [MG2ModalartListItemEntity] {
        try await modalartRepository.getModalartList()
    }

    /// 모다라트의 모각마다 그날 할 수 있는 조각 목록. 모각마다 API를 불러야 해서 하나씩 요청한다.
    func getMogakOccurrences(modalartId: Int, date: Date) async throws -> [MG2MogakOccurrences] {
        var result = [MG2MogakOccurrences]()
        for mogak in try await modalartRepository.getModalartMogaks(modalartId: modalartId) {
            let occurrences = try await modalartRepository.getMogakOccurrences(mogakId: mogak.mogakId, date: date)
            result.append(MG2MogakOccurrences(mogak: mogak, occurrences: occurrences))
        }
        return result
    }
}
