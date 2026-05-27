import Foundation

final class MG2ModalartViewModel {
    private let useCase: ModalartUseCase

    init(useCase: ModalartUseCase? = DIContainer.shared.resolve(ModalartUseCase.self)) {
        guard let useCase else {
            fatalError("ModalartUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        self.useCase = useCase
    }

    func getModalartList(completion: @escaping (Result<[ModalartList]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                let items = try await useCase.getModalartList().map { ModalartList(id: $0.id, title: $0.title) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDetailModalartInfo(modalartId: Int, completion: @escaping (Result<ModalartInfo?, Error>) -> Void) {
        Task { @MainActor in
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

    func getDetailMogakData(modalartId: Int, completion: @escaping (Result<DetailMogakResponse?, Error>) -> Void) {
        Task { @MainActor in
            do {
                let page = try await useCase.getModalartMogakPage(modalartId: modalartId)
                let response = page.map {
                    DetailMogakResponse(
                        time: nil,
                        status: nil,
                        code: nil,
                        message: nil,
                        result: DetailMogak(
                            mogaks: $0.items.map {
                                DetailMogakData(
                                    mogakId: $0.mogakId,
                                    title: $0.title,
                                    bigCategory: MainCategory(id: $0.bigCategoryId, name: $0.bigCategoryName),
                                    smallCategory: $0.smallCategory,
                                    color: $0.color
                                )
                            },
                            size: $0.size
                        )
                    )
                }
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func createModalart(data: ModalartMainData, completion: @escaping (Result<ModalartMainData, Error>) -> Void) {
        Task { @MainActor in
            do {
                let created = try await useCase.createModalart(title: data.title, color: data.color)
                completion(.success(ModalartMainData(id: created.id, title: created.title, color: created.color)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func editModalart(data: ModalartMainData, completion: @escaping (Result<ModalartMainData, Error>) -> Void) {
        Task { @MainActor in
            do {
                let edited = try await useCase.editModalart(id: data.id, title: data.title, color: data.color)
                completion(.success(ModalartMainData(id: edited.id, title: edited.title, color: edited.color)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteModalart(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.deleteModalart(id: id)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getAllMogakDetailJogaks(mogakId: Int, date: String, completion: @escaping (Result<[JogakDetail]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.getMogakDetailJogaks(mogakId: mogakId, date: date)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteMogak(mogakId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.deleteMogak(mogakId: mogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteJogak(jogakId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.deleteJogak(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
