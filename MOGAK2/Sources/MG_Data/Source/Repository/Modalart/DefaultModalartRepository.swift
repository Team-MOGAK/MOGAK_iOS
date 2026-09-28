import Foundation

final class DefaultModalartRepository: ModalartRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getModalartList() async throws -> [MG2ModalartListItemEntity] {
        let response: MG2OptionalResponseDTO<[MG2ModalartListItemDTO]> = try await networkProvider.request(target: MG2ModalartRouter.modalartList)
        return (response.result ?? []).map { $0.toEntity() }
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        let response: MG2OptionalResponseDTO<MG2ModalartDetailDTO> = try await networkProvider.request(target: MG2ModalartRouter.modalartDetail(modalartId: modalartId))
        return response.result?.toEntity()
    }

    func getModalartMogaks(modalartId: Int) async throws -> [MG2ModalartMogakItemEntity] {
        let response: MG2OptionalResponseDTO<MG2ModalartMogakPageDTO> = try await networkProvider.request(target: MG2ModalartRouter.modalartMogaks(modalartId: modalartId))
        return (response.result?.mogaks ?? []).map { $0.toEntity() }
    }

    func getMogakOccurrences(mogakId: Int, date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        let response: MG2ResponseDTO<[MG2JogakOccurrenceDTO]> = try await networkProvider.request(target: MG2ModalartRouter.mogakOccurrences(mogakId: mogakId, date: MG2APIDateCoding.encode(date)))
        return try response.result.map { try $0.toDomain() }
    }

    func createModalart(title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ResponseDTO<MG2ModalartUpsertDTO> = try await networkProvider.request(target: MG2ModalartRouter.modalartCreate(title: title, color: color))
        return response.result.toEntity()
    }

    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ResponseDTO<MG2ModalartUpsertDTO> = try await networkProvider.request(target: MG2ModalartRouter.modalartEdit(id: id, title: title, color: color))
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
