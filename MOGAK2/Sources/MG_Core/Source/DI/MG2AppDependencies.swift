import Foundation

protocol MG2AppDependencies {
    var userState: MG2UserState { get }
    var sessionStore: MG2SessionStoring { get }
}

final class MG2DefaultAppDependencies: MG2AppDependencies {
    let userState: MG2UserState
    let sessionStore: MG2SessionStoring

    init(
        userState: MG2UserState = MG2UserState(),
        sessionStore: MG2SessionStoring = MG2SessionStore()
    ) {
        self.userState = userState
        self.sessionStore = sessionStore
    }
}
