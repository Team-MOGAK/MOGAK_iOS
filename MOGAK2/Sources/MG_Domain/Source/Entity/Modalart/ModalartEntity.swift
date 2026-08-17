import Foundation

struct MG2MogakCategoryEntity: Equatable {
    let code: String?
    let name: String
}

enum MG2MogakCategorySelection {
    case official(code: String)
    case custom(name: String)
}

struct MG2ModalartCategoryEntity {
    let title: String
    let category: MG2MogakCategoryEntity
    let color: String?
}

struct MG2ModalartDetailEntity {
    let id: Int
    let title: String
    let color: String
    let categories: [MG2ModalartCategoryEntity]
}

struct MG2ModalartListItemEntity {
    let id: Int
    let title: String
    let color: String
}

struct MG2ModalartMogakItemEntity {
    let mogakId: Int
    let title: String
    let category: MG2MogakCategoryEntity
    let color: String?
}

struct MG2ModalartMogakPageEntity {
    let items: [MG2ModalartMogakItemEntity]
    let size: Int?
}

struct MG2ModalartUpsertEntity {
    let id: Int
    let title: String
    let color: String
}
