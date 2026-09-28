/// 회원가입·프로필 수정에서 고르는 기본 프로필 이미지 (Assets: profiles/profile1~12)
enum MG2ProfileImage {
    static let ids = Array(1...12)

    static func assetName(for id: Int?) -> String {
        id.map { "profile\($0)" } ?? "setProfile"
    }
}
