import Foundation

protocol ModalartUseCase {
    func getModalartList() async throws -> [MG2ModalartListItemEntity]
    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity?
    func getModalartMogakPage(modalartId: Int) async throws -> MG2ModalartMogakPageEntity?
    func getMogakDetailJogaks(mogakId: Int, date: String) async throws -> [JogakDetail]
    func createModalart(title: String, color: String) async throws -> MG2ModalartUpsertEntity
    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity
    func deleteModalart(id: Int) async throws -> Bool
    func deleteMogak(mogakId: Int) async throws -> Bool
    func deleteJogak(jogakId: Int) async throws -> Bool
}
