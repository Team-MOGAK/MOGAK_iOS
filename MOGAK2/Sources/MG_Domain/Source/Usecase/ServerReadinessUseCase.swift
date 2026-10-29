import Foundation

/// 서버가 깨어날 때까지 기다린다. 업무 API는 이 확인이 끝난 뒤에만 보낸다.
@MainActor
final class ServerReadinessUseCase {
    private static let maxAttempts = 3
    private static let requestTimeout: TimeInterval = 15
    private static let totalTimeout: TimeInterval = 30
    /// full jitter 상한. 첫 재시도는 0~1.5초, 두 번째 재시도는 0~3초 쉰다.
    private static let retryDelayLimits: [TimeInterval] = [1.5, 3]

    private let repository: ServerHealthRepository
    private var isReady = false
    /// 진행 중인 확인. 여러 화면이 불러도 핑은 하나만 보낸다.
    private var inFlight: Task<Bool, Never>?

    init(repository: ServerHealthRepository) {
        self.repository = repository
    }

    /// 준비되면 true, 시도 횟수나 전체 대기 한도를 넘기면 false. 한 번 준비되면 다시 묻지 않는다.
    func waitUntilReady() async -> Bool {
        if isReady { return true }
        if let inFlight { return await inFlight.value }
        let task = Task {
            defer { inFlight = nil }
            isReady = await pollUntilReady()
            return isReady
        }
        inFlight = task
        return await task.value
    }

    /// 최초 요청을 포함해 최대 3번 묻고, 30초 한도를 먼저 넘기면 거기서 멈춘다.
    private func pollUntilReady() async -> Bool {
        let deadline = Date().addingTimeInterval(Self.totalTimeout)
        for attempt in 0..<Self.maxAttempts {
            let timeout = min(Self.requestTimeout, deadline.timeIntervalSinceNow)
            // 남은 시간이 거의 없으면 요청 시간 제한이 0 이하가 되어 기본값(60초)으로 늘어날 수 있다.
            guard timeout > 1 else { return false }
            switch try? await repository.checkReady(timeout: timeout) {
            case .ready?:
                return true
            case .unavailable(let retryAfter)?:
                guard attempt + 1 < Self.maxAttempts else { return false }
                let delay = max(TimeInterval.random(in: 0...Self.retryDelayLimits[attempt]), retryAfter ?? 0)
                guard delay < deadline.timeIntervalSinceNow else { return false }
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            case nil:
                return false
            }
        }
        return false
    }
}
