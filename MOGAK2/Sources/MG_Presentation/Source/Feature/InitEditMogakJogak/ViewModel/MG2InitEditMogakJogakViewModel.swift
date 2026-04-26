import Foundation

final class MG2InitEditMogakJogakViewModel {
    private let useCase: HistoryUseCase

    init(useCase: HistoryUseCase? = DIContainer.shared.resolve(HistoryUseCase.self)) {
        guard let useCase else {
            fatalError("HistoryUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        self.useCase = useCase
    }

    func createMogak(data: MogakMainData, completion: @escaping (Result<CreateMogakMainData, Error>) -> Void) {
        Task {
            do {
                let entity = try await useCase.createMogak(data: data)
                completion(.success(CreateMogakMainData(
                    id: entity.id,
                    title: entity.title,
                    bigCategory: BigCategory(id: entity.bigCategoryId, name: entity.bigCategoryName),
                    smallCategory: entity.smallCategory,
                    color: entity.color
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func editMogak(data: EditMogakRequestMainData, completion: @escaping (Result<EditMogakMainData, Error>) -> Void) {
        Task {
            do {
                let entity = try await useCase.editMogak(data: data)
                completion(.success(EditMogakMainData(
                    id: entity.id,
                    title: entity.title,
                    bigCategory: BigCategory(id: entity.bigCategoryId, name: entity.bigCategoryName),
                    smallCategory: entity.smallCategory,
                    color: entity.color
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func createJogak(data: CreateJogakRequestMainData, completion: @escaping (Result<CreateJogakMainData, Error>) -> Void) {
        Task {
            do {
                let entity = try await useCase.createJogak(data: data)
                completion(.success(CreateJogakMainData(
                    jogakId: entity.jogakId,
                    mogakTitle: entity.mogakTitle,
                    category: entity.category,
                    title: entity.title,
                    isRoutine: entity.isRoutine,
                    days: entity.days,
                    achievements: entity.achievements,
                    startDate: entity.startDate,
                    endDate: entity.endDate
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func editJogak(data: EditJogakRequestMainData, jogakId: Int, completion: @escaping (Result<EditJogakResponse, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await useCase.editJogak(data: data, jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
