import Foundation

protocol HistoryUseCase {
    func createMogak(data: MogakMainData) async throws -> MG2HistoryMogakCreateEntity
    func editMogak(data: EditMogakRequestMainData) async throws -> MG2HistoryMogakEditEntity
    func createJogak(data: CreateJogakRequestMainData) async throws -> MG2HistoryJogakCreateEntity
    func editJogak(data: EditJogakRequestMainData, jogakId: Int) async throws -> EditJogakResponse
    func deleteMogak(mogakId: Int) async throws -> Bool
    func deleteJogak(jogakId: Int) async throws -> Bool
}
