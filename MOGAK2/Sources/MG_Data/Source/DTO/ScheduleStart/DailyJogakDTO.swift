import Foundation

struct MG2DailyJogakListResponseDTO: Decodable {
    let result: MG2DailyJogakListDTO?
}

struct MG2DailyJogakListDTO: Decodable {
    let dailyJogaks: [MG2DailyJogakDTO]?
}

struct MG2DailyJogakDTO: Decodable {
    let jogakID: Int?
    let dailyJogakID: Int
    let title: String
    let isRoutine: Bool
    let isAchievement: Bool

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case dailyJogakID = "dailyJogakId"
        case title
        case isRoutine
        case isAchievement
    }

    func toDomain() -> MG2ScheduleDailyJogakEntity {
        MG2ScheduleDailyJogakEntity(
            id: jogakID,
            dailyID: dailyJogakID,
            title: title,
            isRoutine: isRoutine,
            isAchievement: isAchievement
        )
    }
}
