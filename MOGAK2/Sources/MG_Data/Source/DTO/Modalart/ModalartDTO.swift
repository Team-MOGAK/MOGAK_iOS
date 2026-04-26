import Foundation

struct MG2ModalartListResponseDTO: Decodable {
    let result: [MG2ModalartListItemDTO]?
}

struct MG2ModalartListItemDTO: Decodable {
    let id: Int
    let title: String

    func toEntity() -> MG2ModalartListItemEntity {
        MG2ModalartListItemEntity(id: id, title: title)
    }
}

struct MG2ModalartDetailResponseDTO: Decodable {
    let result: MG2ModalartDetailDTO?
}

struct MG2ModalartDetailDTO: Decodable {
    let id: Int
    let title: String
    let color: String
    let mogakDtoList: [MG2ModalartCategoryDTO]?

    func toEntity() -> MG2ModalartDetailEntity {
        MG2ModalartDetailEntity(
            id: id,
            title: title,
            color: color,
            categories: (mogakDtoList ?? []).map { $0.toEntity() }
        )
    }
}

struct MG2ModalartCategoryDTO: Decodable {
    let title: String
    let bigCategory: MG2BigCategoryDTO
    let smallCategory: String?
    let color: String?

    func toEntity() -> MG2ModalartCategoryEntity {
        MG2ModalartCategoryEntity(
            title: title,
            bigCategoryId: bigCategory.id,
            bigCategoryName: bigCategory.name,
            smallCategory: smallCategory,
            color: color
        )
    }
}

struct MG2BigCategoryDTO: Decodable {
    let id: Int?
    let name: String?
}

struct MG2ModalartMogakPageResponseDTO: Decodable {
    let result: MG2ModalartMogakPageDTO?
}

struct MG2ModalartMogakPageDTO: Decodable {
    let mogaks: [MG2ModalartMogakItemDTO]?
    let size: Int?

    func toEntity() -> MG2ModalartMogakPageEntity {
        MG2ModalartMogakPageEntity(items: (mogaks ?? []).map { $0.toEntity() }, size: size)
    }
}

struct MG2ModalartMogakItemDTO: Decodable {
    let id: Int
    let title: String
    let bigCategory: MG2MainCategoryDTO
    let smallCategory: String?
    let color: String?

    func toEntity() -> MG2ModalartMogakItemEntity {
        MG2ModalartMogakItemEntity(
            mogakId: id,
            title: title,
            bigCategoryId: bigCategory.id,
            bigCategoryName: bigCategory.name,
            smallCategory: smallCategory,
            color: color
        )
    }
}

struct MG2MainCategoryDTO: Decodable {
    let id: Int
    let name: String
}

struct MG2ModalartUpsertResponseDTO: Decodable {
    let result: MG2ModalartUpsertDTO
}

struct MG2ModalartUpsertDTO: Decodable {
    let id: Int
    let title: String
    let color: String

    func toEntity() -> MG2ModalartUpsertEntity {
        MG2ModalartUpsertEntity(id: id, title: title, color: color)
    }
}
