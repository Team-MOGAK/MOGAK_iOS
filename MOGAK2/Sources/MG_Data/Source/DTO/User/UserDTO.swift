import Foundation

struct MG2GetUserProfileResponseDTO: Decodable {
    let result: MG2UserProfileDTO
}

struct MG2UserProfileDTO: Decodable {
    let nickname: String
    let job: String

    func toEntity() -> MG2UserProfileEntity {
        MG2UserProfileEntity(nickname: nickname, job: job)
    }
}

struct MG2UserRegistrationResponseDTO: Decodable {
    let result: MG2UserRegistrationResultDTO
}

struct MG2UserRegistrationResultDTO: Decodable {
    let userId: Int
    let nickname: String
    let tokens: MG2TokenPairDTO

    func toEntity() -> MG2UserRegistrationResult {
        MG2UserRegistrationResult(
            userId: userId,
            nickname: nickname,
            tokens: tokens.toDomain()
        )
    }
}
