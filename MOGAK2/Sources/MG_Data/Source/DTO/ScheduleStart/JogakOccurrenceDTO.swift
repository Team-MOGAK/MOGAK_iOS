import Foundation

struct MG2JogakOccurrencePageDTO: Decodable {
    let size: Int
    let jogaks: [MG2JogakOccurrenceDTO]
}

struct MG2JogakOccurrenceDTO: Decodable {
    let jogakID: Int
    let scheduledDate: String
    let mogakTitle: String
    let category: MG2MogakCategoryDTO
    let title: String
    let color: String?
    let status: MG2JogakOccurrenceStatusDTO
    let isRoutine: Bool
    let achievements: Int

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case scheduledDate, mogakTitle, category, title, color, status, isRoutine, achievements
    }

    func toDomain() throws -> MG2JogakOccurrenceEntity {
        guard let date = MG2APIDateCoding.decode(scheduledDate) else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.scheduledDate], debugDescription: "Invalid date: \(scheduledDate)")) }
        return MG2JogakOccurrenceEntity(key: MG2JogakOccurrenceKey(jogakID: jogakID, scheduledDate: date), mogakTitle: mogakTitle, category: category.toEntity(), title: title, color: color.map(MG2APIColorCoding.decode), status: status.toDomain(), isRoutine: isRoutine, achievements: achievements)
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
