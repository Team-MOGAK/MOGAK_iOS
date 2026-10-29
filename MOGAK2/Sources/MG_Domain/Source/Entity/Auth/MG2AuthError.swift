import Foundation

/// 서버가 리프레시 토큰을 거절했다(만료 · 무효). 다시 로그인해야 한다. 연결 문제 · 서버 오류는 여기에 들지 않는다.
enum MG2AuthError: LocalizedError {
    case sessionExpired

    var errorDescription: String? {
        "로그인이 만료됐어요. 다시 로그인해 주세요"
    }
}
