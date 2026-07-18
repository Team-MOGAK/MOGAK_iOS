import Foundation

struct MG2JogakDetailEntity {
    let jogakID: Int
    let mogakTitle: String
    let category: String
    let title: String
    let isRoutine: Bool
    let days: [MG2Weekday]
    let startDate: Date?
    let endDate: Date?
    let isAlreadyAdded: Bool?
    let achievements: Int
    let color: String?
}
