import Foundation

struct MG2ConsentAgreement {
    let consentItemId: Int
    let agreed: Bool
}

struct MG2ConsentItemEntity {
    let id: Int
    let code: String
    let name: String
    let description: String?
    let required: Bool
}

struct MG2UserRegistration {
    let nickname: String
    let job: String
    let address: String
    let consents: [MG2ConsentAgreement]
}

struct MG2UserRegistrationResult {
    let userId: Int
    let nickname: String
    let tokens: MG2TokenPair
}
