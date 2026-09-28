import Combine

/// 마이페이지와 프로필 수정 화면이 함께 보여주는 프로필. 게스트면 안내 문구를 보여준다.
struct MG2MyPageProfileState {
    let name: String
    let job: String
    let profileImageName: String

    static func publisher(for userState: MG2UserState) -> AnyPublisher<MG2MyPageProfileState, Never> {
        userState.$nickname
            .combineLatest(userState.$job, userState.$loginState, userState.$profileImageID)
            .map { nickname, job, loginState, profileImageID in
                guard loginState != .guest else { return MG2MyPageProfileState(name: "로그인이 필요합니다.", job: "환영합니다!", profileImageName: MG2ProfileImage.assetName(for: nil)) }
                return MG2MyPageProfileState(name: nickname, job: job, profileImageName: MG2ProfileImage.assetName(for: profileImageID))
            }
            .eraseToAnyPublisher()
    }
}
