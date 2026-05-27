import Foundation

final class DefaultHistoryRepository: HistoryRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func createMogak(modaratId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws -> MG2HistoryMogakCreateEntity {
        let response: MG2CreateMogakResponseDTO = try await networkProvider.request(
            target: MG2HistoryRouter.createMogak(modaratId: modaratId, title: title, bigCategory: bigCategory, smallCategory: smallCategory, color: color)
        )
        return response.result.toEntity()
    }

    func editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws -> MG2HistoryMogakEditEntity {
        let response: MG2EditMogakResponseDTO = try await networkProvider.request(
            target: MG2HistoryRouter.editMogak(mogakId: mogakId, title: title, bigCategory: bigCategory, smallCategory: smallCategory, color: color)
        )
        return response.result.toEntity()
    }

    func createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [String]?, today: String?, endDate: String?) async throws -> MG2HistoryJogakCreateEntity {
        let response: MG2CreateJogakResponseDTO = try await networkProvider.request(
            target: MG2HistoryRouter.createJogak(mogakId: mogakId, title: title, isRoutine: isRoutine, days: days, today: today, endDate: endDate)
        )
        return response.result.toEntity()
    }

    func editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [String]?, endDate: String?) async throws -> EditJogakResponse {
        try await networkProvider.request(
            target: MG2HistoryRouter.editJogak(jogakId: jogakId, title: title, isRoutine: isRoutine, days: days, endDate: endDate)
        )
    }

    func deleteMogak(mogakId: Int) async throws -> Bool {
        try await networkProvider.requestEmpty(target: MG2HistoryRouter.deleteMogak(mogakId: mogakId))
        return true
    }

    func deleteJogak(jogakId: Int) async throws -> Bool {
        try await networkProvider.requestEmpty(target: MG2HistoryRouter.deleteJogak(jogakId: jogakId))
        return true
    }
}
