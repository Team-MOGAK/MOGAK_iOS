import Foundation

struct MG2JogakOccurrencePageResponseDTO: Decodable {
    let result: MG2JogakOccurrencePageDTO
}

struct MG2JogakOccurrenceListResponseDTO: Decodable {
    let result: [MG2JogakOccurrenceDTO]
}

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

    func toDomain() -> MG2JogakOccurrenceEntity {
        MG2JogakOccurrenceEntity(
            key: MG2JogakOccurrenceKey(jogakID: jogakID, scheduledDate: scheduledDate),
            mogakTitle: mogakTitle,
            category: category.toEntity(),
            title: title,
            color: color,
            status: status.toDomain(),
            isRoutine: isRoutine,
            achievements: achievements
        )
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
