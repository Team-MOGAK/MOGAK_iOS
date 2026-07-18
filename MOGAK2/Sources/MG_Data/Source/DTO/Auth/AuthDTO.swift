import Foundation

struct MG2AuthLoginResponseDTO: Decodable {
    let status: String
    let result: MG2AuthLoginResultDTO
}

struct MG2AuthLoginResultDTO: Decodable {
    let isRegistered: Bool
    let userId: Int
    let tokens: MG2TokenPairDTO

    func toDomain() -> MG2AuthSession {
        return MG2AuthSession(
            isRegistered: isRegistered,
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
