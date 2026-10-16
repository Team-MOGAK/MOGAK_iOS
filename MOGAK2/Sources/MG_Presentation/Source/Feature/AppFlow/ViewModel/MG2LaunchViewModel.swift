import Foundation

@MainActor
final class MG2LaunchViewModel {
    enum State {
        case waiting
        /// 2초 넘게 서버를 기다리는 중
        case preparing
        case failed
        case ready
    }

    /// 이보다 오래 기다리면 준비 중이라고 알린다.
    private static let preparingDelay: UInt64 = 2_000_000_000

    var onStateChange: ((State) -> Void)?

    private let serverReadinessUseCase: ServerReadinessUseCase

    init(serverReadinessUseCase: ServerReadinessUseCase) {
        self.serverReadinessUseCase = serverReadinessUseCase
    }

    func start() {
        onStateChange?(.waiting)
        let preparing = Task { [weak self] in
            try await Task.sleep(nanoseconds: Self.preparingDelay)
            // 잠에서 깬 직후 응답이 먼저 와서 취소됐을 수도 있다.
            try Task.checkCancellation()
            self?.onStateChange?(.preparing)
        }
        Task { [weak self] in
            guard let self else { return }
            let isReady = await serverReadinessUseCase.waitUntilReady()
            preparing.cancel()
            onStateChange?(isReady ? .ready : .failed)
        }
    }
}
