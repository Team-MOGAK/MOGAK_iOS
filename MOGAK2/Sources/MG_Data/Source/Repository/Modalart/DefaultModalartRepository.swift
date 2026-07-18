import Foundation

final class DefaultModalartRepository: ModalartRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getModalartList() async throws -> [MG2ModalartListItemEntity] {
        let response: MG2ModalartListResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartList)
        return (response.result ?? []).map { $0.toEntity() }
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        let response: MG2ModalartDetailResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartDetail(modalartId: modalartId))
        return response.result?.toEntity()
    }

    func getModalartMogakPage(modalartId: Int) async throws -> MG2ModalartMogakPageEntity? {
        let response: MG2ModalartMogakPageResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartMogaks(modalartId: modalartId))
        return response.result?.toEntity()
    }

    func getMogakDetailJogaks(mogakId: Int, date: Date) async throws -> [MG2JogakDetailEntity] {
        let response: MG2JogakDetailResponseDTO = try await networkProvider.request(
            target: MG2ModalartRouter.mogakDetailJogaks(
                mogakId: mogakId,
                date: MG2APIDateCoding.encode(date)
            )
        )
        return response.result?.map { $0.toEntity() } ?? []
    }

    func createModalart(title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ModalartUpsertResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartCreate(title: title, color: color))
        return response.result.toEntity()
    }

    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ModalartUpsertResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartEdit(id: id, title: title, color: color))
        return response.result.toEntity()
    }

    func deleteModalart(id: Int) async throws {
        try await networkProvider.requestEmpty(target: MG2ModalartRouter.modalartDelete(id: id))
    }

    func deleteMogak(mogakId: Int) async throws {
        try await networkProvider.requestEmpty(target: MG2ModalartRouter.mogakDelete(id: mogakId))
    }

    func deleteJogak(jogakId: Int) async throws {
        try await networkProvider.requestEmpty(target: MG2ModalartRouter.jogakDelete(id: jogakId))
    }
}
