import Foundation

struct MG2CreateMogakResponseDTO: Decodable {
    let result: MG2CreateMogakDTO
}

struct MG2CreateMogakDTO: Decodable {
    let id: Int
    let title: String
    let bigCategory: MG2HistoryBigCategoryDTO
    let smallCategory: String?
    let color: String?

    func toEntity() -> MG2HistoryMogakCreateEntity {
        MG2HistoryMogakCreateEntity(
            id: id,
            title: title,
            bigCategoryId: bigCategory.id,
            bigCategoryName: bigCategory.name,
            smallCategory: smallCategory,
            color: color
        )
    }
}

struct MG2EditMogakResponseDTO: Decodable {
    let result: MG2EditMogakDTO
}

struct MG2EditMogakDTO: Decodable {
    let id: Int
    let title: String
    let bigCategory: MG2HistoryBigCategoryDTO
    let smallCategory: String?
    let color: String

    func toEntity() -> MG2HistoryMogakEditEntity {
        MG2HistoryMogakEditEntity(
            id: id,
            title: title,
            bigCategoryId: bigCategory.id,
            bigCategoryName: bigCategory.name,
            smallCategory: smallCategory,
            color: color
        )
    }
}

struct MG2HistoryBigCategoryDTO: Decodable {
    let id: Int?
    let name: String?
}

struct MG2CreateJogakResponseDTO: Decodable {
    let result: MG2CreateJogakDTO
}

struct MG2CreateJogakDTO: Decodable {
    let jogakId: Int
    let mogakTitle: String
    let category: String
    let title: String
    let isRoutine: Bool
    let days: [String]?
    let achievements: Int
    let startDate: String?
    let endDate: String?

    func toEntity() -> MG2HistoryJogakCreateEntity {
        MG2HistoryJogakCreateEntity(
            jogakId: jogakId,
            mogakTitle: mogakTitle,
            category: category,
            title: title,
            isRoutine: isRoutine,
            days: days,
            achievements: achievements,
            startDate: startDate,
            endDate: endDate
        )
    }
}
