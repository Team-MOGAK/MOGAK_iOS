import Foundation

struct MG2TokenPair {
    let accessToken: String
    let refreshToken: String
}

enum MG2AuthRegistrationStatus {
    case registered
    case signupRequired
    case signupResumeRequired

    var isRegistered: Bool {
        switch self {
        case .registered:
            return true
        case .signupRequired, .signupResumeRequired:
            return false
        }
    }
}

struct MG2AuthSession {
    let registrationStatus: MG2AuthRegistrationStatus
    let userId: Int
    let tokens: MG2TokenPair

    var isRegistered: Bool { registrationStatus.isRegistered }
}
