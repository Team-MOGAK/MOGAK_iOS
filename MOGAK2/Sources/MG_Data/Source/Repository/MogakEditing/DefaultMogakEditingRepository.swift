import Foundation

final class DefaultMogakEditingRepository: MogakEditingRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func createMogak(modaratId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws {
        try await networkProvider.requestEmpty(
            target: MG2MogakEditingRouter.createMogak(modaratId: modaratId, title: title, bigCategory: bigCategory, smallCategory: smallCategory, color: color)
        )
    }

    func editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String) async throws {
        try await networkProvider.requestEmpty(
            target: MG2MogakEditingRouter.editMogak(mogakId: mogakId, title: title, bigCategory: bigCategory, smallCategory: smallCategory, color: color)
        )
    }

    func createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [MG2Weekday]?, today: Date, endDate: Date?) async throws {
        try await networkProvider.requestEmpty(
            target: MG2MogakEditingRouter.createJogak(
                mogakId: mogakId,
                title: title,
                isRoutine: isRoutine,
                days: days.map(MG2APIWeekdayCoding.encode),
                today: MG2APIDateCoding.encode(today),
                endDate: endDate.map(MG2APIDateCoding.encode)
            )
        )
    }

    func editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [MG2Weekday]?, endDate: Date?) async throws {
        try await networkProvider.requestEmpty(
            target: MG2MogakEditingRouter.editJogak(
                jogakId: jogakId,
                title: title,
                isRoutine: isRoutine,
                days: days.map(MG2APIWeekdayCoding.encode),
                endDate: endDate.map(MG2APIDateCoding.encode)
            )
        )
    }

}
