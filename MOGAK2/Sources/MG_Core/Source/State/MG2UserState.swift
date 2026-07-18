import Combine
import Foundation

final class MG2UserState {
    @Published var loginState: MG2LoginStatus?
    @Published var isRegistered = false
    @Published var profileImageData: Data?
    @Published var nickname = ""
    @Published var job = ""
    @Published var region = ""

    init() {}

    func resetProfile() {
        nickname = ""
        job = ""
        region = ""
        profileImageData = nil
    }
}
