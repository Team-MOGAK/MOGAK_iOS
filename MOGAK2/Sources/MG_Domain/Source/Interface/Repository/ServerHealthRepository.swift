import Foundation

/// 서버 준비 상태를 한 번 확인한 결과.
enum MG2ServerHealth: Equatable {
    case ready
    /// 콜드스타트 중이거나 연결이 안 되는 일시 오류. retryAfter는 서버가 알려준 최소 대기 시간(초).
    case unavailable(retryAfter: TimeInterval?)
}

protocol ServerHealthRepository {
    /// 일시 오류가 아닌 실패는 던진다.
    func checkReady(timeout: TimeInterval) async throws -> MG2ServerHealth
}
