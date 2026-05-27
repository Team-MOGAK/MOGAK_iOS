import Foundation

final class MG2ScheduleStartViewModel {
    private let useCase: ScheduleStartUseCase

    init(
        useCase: ScheduleStartUseCase? = DIContainer.shared.resolve(ScheduleStartUseCase.self)
    ) {
        guard let useCase else {
            fatalError("ScheduleStartUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        self.useCase = useCase
    }

    func getModalartList(completion: @escaping (Result<[ScheduleModalartList]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                let modalarts = try await useCase.getModalartList().map {
                    ScheduleModalartList(id: $0.id, title: $0.title, color: $0.color)
                }
                completion(.success(modalarts))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDetailModalartInfo(modalartId: Int, completion: @escaping (Result<ScheduleModalartInfo?, Error>) -> Void) {
        Task { @MainActor in
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
        Task { @MainActor in
            do {
                let page = try await useCase.getMogakPage(modalartId: modalartId)
                let response = ScheduleDetailMogakResponse(
                    time: nil,
                    status: nil,
                    code: nil,
                    message: nil,
                    result: ScheduleDetailMogak(
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
                )
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getAllMogakDetailJogaks(mogakId: Int, dailyDate: String, completion: @escaping (Result<[ScheduleJogakDetail]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.getMogakDetailJogaks(mogakId: mogakId, dailyDate: dailyDate)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getCheckDailyJogak(dailyDate: String, completion: @escaping (Result<[JogakDailyCheck]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.getCheckDailyJogak(dailyDate: dailyDate)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getAddJogakDaily(jogakId: Int, completion: @escaping (Result<[JogakDailyStartResponse]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.addJogakDaily(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getdailyJogakDetail(jogakId: Int, completion: @escaping (Result<DailyJogakDetail?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.getDailyJogakDetail(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getJogakFail(dailyJogakId: Int, completion: @escaping (Result<[JogakFail]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.jogakFail(dailyJogakId: dailyJogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getJogakSuccess(dailyJogakId: Int, completion: @escaping (Result<[JogakSuccess]?, Error>) -> Void) {
        Task { @MainActor in
            do {
                completion(.success(try await useCase.jogakSuccess(dailyJogakId: dailyJogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
