import Foundation

final class DefaultMogakEditingUseCase: MogakEditingUseCase {

    private let repository: MogakEditingRepository

    init(repository: MogakEditingRepository) {
        self.repository = repository
    }

    func createMogak(
        modaratId: Int,
        title: String,
        bigCategory: String,
        smallCategory: String?,
        color: String
    ) async throws {
        try await repository.createMogak(
            modaratId: modaratId,
            title: title,
            bigCategory: bigCategory,
            smallCategory: smallCategory,
            color: color
        )
    }

    func editMogak(
        mogakId: Int,
        title: String,
        bigCategory: String,
        smallCategory: String?,
        color: String
    ) async throws {
        try await repository.editMogak(
            mogakId: mogakId,
            title: title,
            bigCategory: bigCategory,
            smallCategory: smallCategory,
            color: color
        )
    }

    func createJogak(
        mogakId: Int,
        title: String,
        isRoutine: Bool,
        days: [MG2Weekday]?,
        today: Date,
        endDate: Date?
    ) async throws {
        try await repository.createJogak(
            mogakId: mogakId,
            title: title,
            isRoutine: isRoutine,
            days: days,
            today: today,
            endDate: endDate
        )
    }

    func editJogak(
        jogakId: Int,
        title: String,
        isRoutine: Bool,
        days: [MG2Weekday]?,
        endDate: Date?
    ) async throws {
        try await repository.editJogak(
            jogakId: jogakId,
            title: title,
            isRoutine: isRoutine,
            days: days,
            endDate: endDate
        )
    }

}
