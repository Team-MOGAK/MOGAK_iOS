import Foundation

struct MG2ModalartCategoryEntity {
    let title: String
    let bigCategoryId: Int?
    let bigCategoryName: String?
    let smallCategory: String?
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
    let bigCategoryId: Int
    let bigCategoryName: String
    let smallCategory: String?
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
