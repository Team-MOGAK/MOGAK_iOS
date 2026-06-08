import Foundation

@MainActor
final class MG2MyHistoryViewModel {
    private let useCase: ModalartUseCase

    init(useCase: ModalartUseCase) {
        self.useCase = useCase
    }

    func getModalartList(completion: @escaping (Result<[ModalartList]?, Error>) -> Void) {
        Task {
            do {
                let items = try await useCase.getModalartList().map {
                    ModalartList(id: $0.id, title: $0.title)
                }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDetailModalartInfo(modalartId: Int, completion: @escaping (Result<ModalartInfo?, Error>) -> Void) {
        Task {
            do {
                let detail = try await useCase.getModalartDetail(modalartId: modalartId)
                let mapped = detail.map {
                    ModalartInfo(
                        id: $0.id,
                        title: $0.title,
                        color: $0.color,
                        mogakCategory: $0.categories.map {
                            MogakCategory(
                                title: $0.title,
                                bigCategory: BigCategory(id: $0.bigCategoryId, name: $0.bigCategoryName),
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
}
