import Foundation

final class DefaultMogakEditingRepository: MogakEditingRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getMogakCategories() async throws -> [MG2MogakCategoryEntity] {
        let response: MG2ResponseDTO<[MG2MogakCategoryDTO]> = try await networkProvider.request(target: MG2MogakEditingRouter.categories)
        return response.result.map { $0.toEntity() }
    }

    func createMogak(modalartID: Int, title: String, category: MG2MogakCategorySelection, color: String) async throws {
        try await networkProvider.requestEmpty(target: MG2MogakEditingRouter.createMogak(modalartID: modalartID, title: title, category: category, color: color))
    }

    func editMogak(mogakId: Int, title: String, category: MG2MogakCategorySelection, color: String) async throws {
        try await networkProvider.requestEmpty(target: MG2MogakEditingRouter.editMogak(mogakID: mogakId, title: title, category: category, color: color))
    }

    func createJogak(mogakId: Int, title: String, schedule: MG2JogakSchedule) async throws {
        try await networkProvider.requestEmpty(target: MG2MogakEditingRouter.createJogak(mogakID: mogakId, title: title, schedule: schedule))
    }

    func editJogak(jogakId: Int, title: String, schedule: MG2JogakSchedule?) async throws {
        try await networkProvider.requestEmpty(target: MG2MogakEditingRouter.editJogak(jogakID: jogakId, title: title, schedule: schedule))
    }
}
