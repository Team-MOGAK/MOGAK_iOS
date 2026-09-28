/// 로그인 세션을 기기에 저장하는 곳. 구현은 MG_Core에 있다.
protocol SessionStorage {
    var refreshToken: String? { get }
    var isFirstTime: Bool { get }
    var storedUserIsRegistered: Bool? { get }

    func saveSession(tokens: MG2TokenPair, userID: Int, isRegistered: Bool)
    func saveTokens(_ tokens: MG2TokenPair)
    func setFirstTime(_ isFirstTime: Bool)
    func clearAuthentication()
    func resetAfterWithdrawal()
}
