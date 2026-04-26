import Foundation

protocol HistoryRepository {
    func createMogak(title: String, bigCategory: String, smallCategory: String?, color: String) async throws -> MG2HistoryMogakCreateEntity
    func editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws -> MG2HistoryMogakEditEntity
    func createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [String]?, today: String?, endDate: String?) async throws -> MG2HistoryJogakCreateEntity
    func editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [String]?, endDate: String?) async throws -> EditJogakResponse
    func deleteMogak(mogakId: Int) async throws -> Bool
    func deleteJogak(jogakId: Int) async throws -> Bool
}
