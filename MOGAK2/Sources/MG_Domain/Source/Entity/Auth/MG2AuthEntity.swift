import Foundation

struct MG2TokenPair {
    let accessToken: String
    let refreshToken: String
}

struct MG2AuthSession {
    let isRegistered: Bool
    let userId: Int
    let tokens: MG2TokenPair
}
