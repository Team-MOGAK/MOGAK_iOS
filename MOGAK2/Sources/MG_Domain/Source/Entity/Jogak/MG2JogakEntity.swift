import Foundation

enum MG2JogakOccurrenceStatus: String {
    case pending = "PENDING"
    case missed = "MISSED"
    case inProgress = "IN_PROGRESS"
    case success = "SUCCESS"
    case fail = "FAIL"
}

struct MG2JogakOccurrenceKey: Hashable {
    let jogakID: Int
    let scheduledDate: String
}

struct MG2JogakOccurrenceEntity {
    let key: MG2JogakOccurrenceKey
    let mogakTitle: String
    let category: MG2MogakCategoryEntity
    let title: String
    let color: String?
    let status: MG2JogakOccurrenceStatus
    let isRoutine: Bool
    let achievements: Int
}

enum MG2JogakSchedule: Equatable {
    case once(effectiveFrom: Date)
    case weekly(
        effectiveFrom: Date,
        effectiveTo: Date?,
        weekdays: [MG2Weekday]
    )
}
