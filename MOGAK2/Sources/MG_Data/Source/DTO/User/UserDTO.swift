import Foundation

struct MG2MetadataItemDTO: Decodable {
    let name: String
}

struct MG2ConsentItemDTO: Decodable {
    let id: Int
    let code: String
    let name: String
    let description: String?
    let required: Bool

    func toEntity() -> MG2ConsentItemEntity {
        MG2ConsentItemEntity(id: id, code: code, name: name, description: description, required: required)
    }
}

struct MG2UserProfileDTO: Decodable {
    let nickname: String
    let job: String

    func toEntity(profileImageID: Int?) -> MG2UserProfileEntity {
        MG2UserProfileEntity(nickname: nickname, job: job, profileImageID: profileImageID)
    }
}

struct MG2UserRegistrationResultDTO: Decodable {
    let userId: Int
    let nickname: String
    let tokens: MG2TokenPairDTO

    func toEntity() -> MG2UserRegistrationResult {
        MG2UserRegistrationResult(userId: userId, nickname: nickname, tokens: tokens.toDomain())
    }
}
