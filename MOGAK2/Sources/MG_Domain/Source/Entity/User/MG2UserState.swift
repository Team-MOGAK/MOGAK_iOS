import Combine

/// 지금 사용자의 로그인·프로필 상태. 값은 AuthUseCase·UserUseCase만 바꾸고, 화면은 구독만 한다.
final class MG2UserState {
    @Published var loginState: MG2LoginStatus?
    @Published var isRegistered = false
    @Published var nickname = ""
    @Published var job = ""
    @Published var profileImageID: Int?

    init() {}

    func resetProfile() {
        nickname = ""
        job = ""
        profileImageID = nil
    }
}
