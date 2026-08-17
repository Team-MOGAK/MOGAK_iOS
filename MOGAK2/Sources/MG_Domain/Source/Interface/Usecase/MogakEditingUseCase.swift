import Foundation

protocol MogakEditingUseCase {
    func getMogakCategories() async throws -> [MG2MogakCategoryEntity]
    func createMogak(
        modaratId: Int,
        title: String,
        category: MG2MogakCategorySelection,
        color: String
    ) async throws
    func editMogak(
        mogakId: Int,
        title: String,
        category: MG2MogakCategorySelection,
        color: String
    ) async throws
    func createJogak(
        mogakId: Int,
        title: String,
        schedule: MG2JogakSchedule
    ) async throws
    func editJogak(
        jogakId: Int,
        title: String,
        schedule: MG2JogakSchedule?
    ) async throws
}
