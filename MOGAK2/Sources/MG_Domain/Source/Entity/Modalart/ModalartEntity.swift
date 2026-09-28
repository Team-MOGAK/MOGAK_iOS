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

    var hasDefaultTitle: Bool { MG2ModalartDefaultTitle.isDefault(title) }
}

/// 사용자가 제목을 정하기 전 모다라트에 붙는 "내 모다라트N" 제목 규칙
enum MG2ModalartDefaultTitle {
    private static let prefix = "내 모다라트"

    static func isDefault(_ title: String) -> Bool {
        sequence(of: title) != nil
    }

    static func next(after titles: [String]) -> String {
        prefix + String((titles.compactMap(sequence(of:)).max() ?? 0) + 1)
    }

    private static func sequence(of title: String) -> Int? {
        guard title.hasPrefix(prefix) else { return nil }
        return Int(title.dropFirst(prefix.count))
    }
}

struct MG2ModalartMogakItemEntity {
    let mogakId: Int
    let title: String
    let category: MG2MogakCategoryEntity
    let color: String?
}

struct MG2ModalartUpsertEntity {
    let id: Int
    let title: String
    let color: String
}
