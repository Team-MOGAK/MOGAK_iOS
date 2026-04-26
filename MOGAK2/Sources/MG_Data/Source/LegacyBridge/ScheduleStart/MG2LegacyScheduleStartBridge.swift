import Foundation

final class MG2LegacyScheduleStartBridge {

    static let shared = MG2LegacyScheduleStartBridge()

    private let provider: NetworkProvider

    private init() {
        self.provider = DefaultNetworkProvider(session: .default)
    }

    func scheduleJogakList(mogakId: Int, dailyDate: String, completion: @escaping (Result<[ScheduleJogakDetail]?, Error>) -> Void) {
        Task {
            do {
                let response: ScheduleJogakDetailResponse = try await provider.request(
                    target: MG2ScheduleStartRouter.jogakList(mogakId: mogakId, date: dailyDate)
                )
                completion(.success(response.result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleDailyCheck(dailyDate: String, completion: @escaping (Result<[JogakDailyCheck]?, Error>) -> Void) {
        Task {
            do {
                let response: JogakDailyCheck = try await provider.request(
                    target: MG2ScheduleStartRouter.jogakDailyCheck(date: dailyDate)
                )
                completion(.success([response]))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleAddJogakDaily(jogakId: Int, completion: @escaping (Result<[JogakDailyStartResponse]?, Error>) -> Void) {
        Task {
            do {
                let _: JogakDailyStart = try await provider.request(
                    target: MG2ScheduleStartRouter.addJogakToday(jogakId: jogakId)
                )
                completion(.success(nil))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleDailyJogakDetail(jogakId: Int, completion: @escaping (Result<DailyJogakDetail?, Error>) -> Void) {
        Task {
            do {
                let response: DailyJogakDetail = try await provider.request(
                    target: MG2ScheduleStartRouter.dailyJogakDetail(jogakId: jogakId)
                )
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleJogakFail(dailyJogakId: Int, completion: @escaping (Result<[JogakFail]?, Error>) -> Void) {
        Task {
            do {
                let response: JogakFail = try await provider.request(
                    target: MG2ScheduleStartRouter.jogakFail(dailyJogakId: dailyJogakId)
                )
                completion(.success([response]))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleJogakSuccess(dailyJogakId: Int, completion: @escaping (Result<[JogakSuccess]?, Error>) -> Void) {
        Task {
            do {
                let response: JogakSuccess = try await provider.request(
                    target: MG2ScheduleStartRouter.jogakSuccess(dailyJogakId: dailyJogakId)
                )
                completion(.success([response]))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func scheduleJogakMonth(startDay: String, endDay: String, completion: @escaping (Result<[JogakMonth], Error>) -> Void) {
        Task {
            do {
                let response: JogakMonth = try await provider.request(
                    target: MG2ScheduleStartRouter.jogakMonth(startDay: startDay, endDay: endDay)
                )
                completion(.success([response]))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
