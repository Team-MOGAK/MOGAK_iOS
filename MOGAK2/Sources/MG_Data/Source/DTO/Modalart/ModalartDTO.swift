import Foundation

struct MG2ModalartListItemDTO: Decodable {
    let id: Int
    let title: String
    let color: String

    func toEntity() -> MG2ModalartListItemEntity {
        MG2ModalartListItemEntity(id: id, title: title, color: MG2APIColorCoding.decode(color))
    }
}

struct MG2ModalartDetailDTO: Decodable {
    let id: Int
    let title: String
    let color: String
    let mogaks: [MG2ModalartCategoryDTO]?

    func toEntity() -> MG2ModalartDetailEntity {
        MG2ModalartDetailEntity(id: id, title: title, color: MG2APIColorCoding.decode(color), categories: (mogaks ?? []).map { $0.toEntity() })
    }
}

struct MG2ModalartCategoryDTO: Decodable {
    let title: String
    let category: MG2MogakCategoryDTO
    let color: String?

    func toEntity() -> MG2ModalartCategoryEntity {
        MG2ModalartCategoryEntity(title: title, category: category.toEntity(), color: color.map(MG2APIColorCoding.decode))
    }
}

struct MG2MogakCategoryDTO: Decodable {
    let code: String?
    let name: String

    func toEntity() -> MG2MogakCategoryEntity {
        MG2MogakCategoryEntity(code: code, name: name)
    }
}

struct MG2ModalartMogakPageDTO: Decodable {
    let mogaks: [MG2ModalartMogakItemDTO]?
}

struct MG2ModalartMogakItemDTO: Decodable {
    let id: Int
    let title: String
    let category: MG2MogakCategoryDTO
    let color: String?

    func toEntity() -> MG2ModalartMogakItemEntity {
        MG2ModalartMogakItemEntity(mogakId: id, title: title, category: category.toEntity(), color: color.map(MG2APIColorCoding.decode))
    }
}

struct MG2ModalartUpsertDTO: Decodable {
    let id: Int
    let title: String
    let color: String

    func toEntity() -> MG2ModalartUpsertEntity {
        MG2ModalartUpsertEntity(id: id, title: title, color: MG2APIColorCoding.decode(color))
    }
}
