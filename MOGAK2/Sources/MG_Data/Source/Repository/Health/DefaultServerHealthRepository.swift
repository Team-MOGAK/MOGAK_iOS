import Foundation

final class DefaultServerHealthRepository: ServerHealthRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    /// 502·503·504·429와 연결 오류·timeout은 일시 오류다. 나머지 HTTP 실패는 그대로 던진다.
    func checkReady(timeout: TimeInterval) async throws -> MG2ServerHealth {
        do {
            try await networkProvider.requestEmpty(target: MG2HealthRouter.ready(timeout: timeout))
            return .ready
        } catch let error as MG2NetworkError {
            switch error {
            case .rateLimited(_, let retryAfter):
                return .unavailable(retryAfter: retryAfter)
            case .storageUnavailable:
                return .unavailable(retryAfter: nil)
            case .httpFailure(let statusCode, _, _):
                guard [502, 503, 504].contains(statusCode) else { throw error }
                return .unavailable(retryAfter: nil)
            }
        } catch {
            return .unavailable(retryAfter: nil)
        }
    }
}
