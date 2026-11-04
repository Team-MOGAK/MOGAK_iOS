import Foundation

struct MG2JogakOccurrencePageDTO: Decodable {
    let size: Int
    let jogaks: [MG2JogakOccurrenceDTO]
}

struct MG2JogakOccurrenceDTO: Decodable {
    let jogakID: Int
    let mogakID: Int
    let modalartID: Int
    let scheduledDate: String
    let mogakTitle: String
    let category: MG2MogakCategoryDTO
    let title: String
    let color: String?
    let status: MG2JogakOccurrenceStatusDTO
    let isRoutine: Bool
    let days: [String]
    let achievements: Int

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakID = "mogakId"
        case modalartID = "modaratId"
        case scheduledDate, mogakTitle, category, title, color, status, isRoutine, days, achievements
    }

    func toDomain() throws -> MG2JogakOccurrenceEntity {
        guard let date = MG2APIDateCoding.decode(scheduledDate) else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.scheduledDate], debugDescription: "Invalid date: \(scheduledDate)")) }
        return MG2JogakOccurrenceEntity(key: MG2JogakOccurrenceKey(jogakID: jogakID, scheduledDate: date), mogakID: mogakID, modalartID: modalartID, mogakTitle: mogakTitle, category: category.toEntity(), title: title, color: color.map(MG2APIColorCoding.decode), status: status.toDomain(), isRoutine: isRoutine, days: MG2APIWeekdayCoding.decode(days), achievements: achievements)
    }
}

/// `date` 없이 부른 모각 조각 목록. `scheduledDate` · `status`는 null이라 읽지 않는다.
struct MG2MogakJogakDTO: Decodable {
    let jogakID: Int
    let title: String
    let isRoutine: Bool
    let days: [String]

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case title, isRoutine, days
    }

    func toEntity() -> MG2MogakJogakEntity {
        MG2MogakJogakEntity(jogakID: jogakID, title: title, isRoutine: isRoutine, days: MG2APIWeekdayCoding.decode(days))
    }
}

enum MG2JogakOccurrenceStatusDTO: String, Decodable {
    case pending = "PENDING"
    case missed = "MISSED"
    case inProgress = "IN_PROGRESS"
    case success = "SUCCESS"
    case fail = "FAIL"

    func toDomain() -> MG2JogakOccurrenceStatus {
        switch self {
        case .pending: .pending
        case .missed: .missed
        case .inProgress: .inProgress
        case .success: .success
        case .fail: .fail
        }
    }
}
