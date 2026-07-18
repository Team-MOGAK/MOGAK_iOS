import Foundation

struct MG2UserRegistration {
    let nickname: String
    let job: String
    let address: String
}

struct MG2UserRegistrationResult {
    let userId: Int
    let nickname: String
    let tokens: MG2TokenPair
}
