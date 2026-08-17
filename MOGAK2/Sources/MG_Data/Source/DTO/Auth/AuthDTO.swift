import Foundation

struct MG2AuthLoginResponseDTO: Decodable {
    let status: String
    let code: String
    let result: MG2AuthLoginResultDTO

    func toDomain() -> MG2AuthSession {
        let registrationStatus: MG2AuthRegistrationStatus
        if code == "AUTH_SIGNUP_RESUME_REQUIRED" {
            registrationStatus = .signupResumeRequired
        } else {
            registrationStatus = result.isRegistered ? .registered : .signupRequired
        }

        return result.toDomain(registrationStatus: registrationStatus)
    }
}

struct MG2AuthLoginResultDTO: Decodable {
    let isRegistered: Bool
    let userId: Int
    let tokens: MG2TokenPairDTO

    func toDomain(registrationStatus: MG2AuthRegistrationStatus) -> MG2AuthSession {
        return MG2AuthSession(
            registrationStatus: registrationStatus,
            userId: userId,
            tokens: tokens.toDomain()
        )
    }
}

struct MG2TokenPairDTO: Decodable {
    let accessToken: String
    let refreshToken: String

    func toDomain() -> MG2TokenPair {
        return MG2TokenPair(accessToken: accessToken, refreshToken: refreshToken)
    }
}

struct MG2RefreshResponseDTO: Decodable {
    let status: String
    let result: MG2TokenPairDTO
}

struct MG2WithdrawResponseDTO: Decodable {
    let result: MG2WithdrawResultDTO
}

struct MG2WithdrawResultDTO: Decodable {
    let isDeleted: Bool
}
