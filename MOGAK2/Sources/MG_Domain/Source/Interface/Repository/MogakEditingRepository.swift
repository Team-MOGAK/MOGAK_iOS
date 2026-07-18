import Foundation

protocol MogakEditingRepository {
    func createMogak(modaratId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws
    func editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws
    func createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [MG2Weekday]?, today: Date, endDate: Date?) async throws
    func editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [MG2Weekday]?, endDate: Date?) async throws
}
