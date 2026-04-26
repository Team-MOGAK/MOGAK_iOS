import Foundation

struct MG2GetUserProfileResponseDTO: Decodable {
    let result: MG2UserProfileDTO
}

struct MG2UserProfileDTO: Decodable {
    let nickname: String
    let job: String
    let imgUrl: String?

    func toEntity() -> MG2UserProfileEntity {
        MG2UserProfileEntity(nickname: nickname, job: job, imageURL: imgUrl)
    }
}
