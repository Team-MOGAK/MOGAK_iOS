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

    func getMogakDetailJogaks(mogakId: Int, date: Date) async throws -> [MG2JogakDetailEntity] {
        try await repository.getMogakDetailJogaks(mogakId: mogakId, date: date)
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
