/// 소셜 SDK에서 서버 로그인에 쓸 토큰을 받아오는 곳. 구현은 MG_App(SDK 연동)에 있다.
@MainActor
protocol SocialTokenProvider {
    func token(for provider: MG2SocialLoginProvider) async throws -> String
}
