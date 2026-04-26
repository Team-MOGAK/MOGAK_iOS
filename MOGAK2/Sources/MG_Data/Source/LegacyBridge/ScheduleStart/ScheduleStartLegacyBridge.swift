import Foundation

/// Transitional adapter used while MOGAK1 scenes are still alive.
/// It maps MOGAK2 use case results into legacy MOGAK1 response models.
final class ScheduleStartLegacyBridge {

    static let shared = ScheduleStartLegacyBridge()

    private let useCase: ScheduleStartUseCase

    private init() {
        let provider = DefaultNetworkProvider(session: .default)
        let repository = DefaultScheduleStartRepository(networkProvider: provider)
        self.useCase = DefaultScheduleStartUseCase(repository: repository)
    }

    func getModalartList(completion: @escaping (Result<[ScheduleModalartList]?, Error>) -> Void) {
        Task {
            do {
                let items = try await useCase.getModalartList()
                    .map { ScheduleModalartList(id: $0.id, title: $0.title, color: $0.color) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getModalartDetail(modalartId: Int, completion: @escaping (Result<ScheduleModalartInfo?, Error>) -> Void) {
        Task {
            do {
                let detail = try await useCase.getModalartDetail(modalartId: modalartId)
                let mapped = detail.map {
                    ScheduleModalartInfo(
                        id: $0.id,
                        title: $0.title,
                        color: $0.color,
                        mogakCategory: $0.mogaks.map {
                            ScheduleMogakCategory(
                                title: $0.title,
                                bigCategory: ScheduleBigCategory(id: $0.bigCategory.id, name: $0.bigCategory.name),
                                smallCategory: $0.smallCategory,
                                color: $0.color
                            )
                        }
                    )
                }
                completion(.success(mapped))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDetailMogakData(modalartId: Int, completion: @escaping (Result<ScheduleDetailMogakResponse?, Error>) -> Void) {
        Task {
            do {
                let page = try await useCase.getMogakPage(modalartId: modalartId)
                let result = ScheduleDetailMogak(
                    mogaks: page.mogaks.map {
                        ScheduleDetailMogakData(
                            mogakId: $0.id,
                            title: $0.title,
                            state: $0.state,
                            bigCategory: ScheduleMainCategory(id: $0.bigCategory.id, name: $0.bigCategory.name),
                            smallCategory: $0.smallCategory,
                            color: $0.color,
                            startAt: $0.startAt,
                            endAt: $0.endAt
                        )
                    },
                    size: page.totalCount
                )

                completion(
                    .success(
                        ScheduleDetailMogakResponse(
                            time: nil,
                            status: nil,
                            code: nil,
                            message: nil,
                            result: result
                        )
                    )
                )
            } catch {
                completion(.failure(error))
            }
        }
    }
}
