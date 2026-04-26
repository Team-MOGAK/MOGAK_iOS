import Foundation

struct MG2HistoryMogakCreateEntity {
    let id: Int
    let title: String
    let bigCategoryId: Int?
    let bigCategoryName: String?
    let smallCategory: String?
    let color: String?
}

struct MG2HistoryMogakEditEntity {
    let id: Int
    let title: String
    let bigCategoryId: Int?
    let bigCategoryName: String?
    let smallCategory: String?
    let color: String
}

struct MG2HistoryJogakCreateEntity {
    let jogakId: Int
    let mogakTitle: String
    let category: String
    let title: String
    let isRoutine: Bool
    let days: [String]?
    let achievements: Int
    let startDate: String?
    let endDate: String?
}
