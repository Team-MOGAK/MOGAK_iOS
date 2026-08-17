import Foundation

final class DefaultMogakEditingUseCase: MogakEditingUseCase {

    private let repository: MogakEditingRepository

    init(repository: MogakEditingRepository) {
        self.repository = repository
    }

    func getMogakCategories() async throws -> [MG2MogakCategoryEntity] {
        try await repository.getMogakCategories()
    }

    func createMogak(
        modaratId: Int,
        title: String,
        category: MG2MogakCategorySelection,
        color: String
    ) async throws {
        try await repository.createMogak(
            modaratId: modaratId,
            title: title,
            category: category,
            color: color
        )
    }

    func editMogak(
        mogakId: Int,
        title: String,
        category: MG2MogakCategorySelection,
        color: String
    ) async throws {
        try await repository.editMogak(
            mogakId: mogakId,
            title: title,
            category: category,
            color: color
        )
    }

    func createJogak(
        mogakId: Int,
        title: String,
        schedule: MG2JogakSchedule
    ) async throws {
        try await repository.createJogak(
            mogakId: mogakId,
            title: title,
            schedule: schedule
        )
    }

    func editJogak(
        jogakId: Int,
        title: String,
        schedule: MG2JogakSchedule?
    ) async throws {
        try await repository.editJogak(
            jogakId: jogakId,
            title: title,
            schedule: schedule
        )
    }

}
