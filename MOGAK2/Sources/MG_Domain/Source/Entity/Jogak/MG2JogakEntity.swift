import Foundation

enum MG2JogakOccurrenceStatus {
    case pending
    case missed
    case inProgress
    case success
    case fail
}

struct MG2JogakOccurrenceKey: Hashable {
    let jogakID: Int
    let scheduledDate: Date
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

struct MG2MogakOccurrences {
    let mogak: MG2ModalartMogakItemEntity
    let occurrences: [MG2JogakOccurrenceEntity]
}

enum MG2JogakSchedule: Equatable {
    case once(effectiveFrom: Date)
    case weekly(effectiveFrom: Date, effectiveTo: Date?, weekdays: [MG2Weekday])
}
