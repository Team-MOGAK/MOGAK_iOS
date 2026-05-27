import Foundation

final class DefaultHistoryUseCase: HistoryUseCase {

    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func createMogak(data: MogakMainData) async throws -> MG2HistoryMogakCreateEntity {
        try await repository.createMogak(modaratId: data.modaratId, title: data.title, bigCategory: data.bigCategory, smallCategory: data.smallCategory, color: data.color)
    }

    func editMogak(data: EditMogakRequestMainData) async throws -> MG2HistoryMogakEditEntity {
        try await repository.editMogak(mogakId: data.mogakId, title: data.title, bigCategory: data.bigCategory, smallCategory: data.smallCategory, color: data.color)
    }

    func createJogak(data: CreateJogakRequestMainData) async throws -> MG2HistoryJogakCreateEntity {
        try await repository.createJogak(
            mogakId: data.mogakId,
            title: data.title,
            isRoutine: data.isRoutine,
            days: data.days,
            today: data.today,
            endDate: data.endDate
        )
    }

    func editJogak(data: EditJogakRequestMainData, jogakId: Int) async throws -> EditJogakResponse {
        try await repository.editJogak(jogakId: jogakId, title: data.title, isRoutine: data.isRoutine, days: data.days, endDate: data.endDate)
    }

    func deleteMogak(mogakId: Int) async throws -> Bool {
        try await repository.deleteMogak(mogakId: mogakId)
    }

    func deleteJogak(jogakId: Int) async throws -> Bool {
        try await repository.deleteJogak(jogakId: jogakId)
    }
}
