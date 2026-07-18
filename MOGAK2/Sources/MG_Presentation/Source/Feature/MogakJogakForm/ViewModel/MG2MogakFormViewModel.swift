import Foundation

enum MG2MogakFormMode {
    case create(modalartID: Int)
    case edit(MG2ModalartMogakItemEntity)
}

struct MG2MogakFormState {
    var title = ""
    var bigCategory = ""
    var customCategory: String?
    var color = DesignSystemPalette.signatureHex
}

@MainActor
final class MG2MogakFormViewModel {
    private static let customCategoryTitle = "기타"

    let colors = DesignSystemPalette.mogakColors
    let categories = [
        "자격증", "대외활동", "운동", "인사이트",
        "공모전", "직무공부", "산업분석", "어학",
        "강연,강의", "프로젝트", "스터디", "기타"
    ]

    private let useCase: MogakEditingUseCase
    private(set) var state = MG2MogakFormState()

    init(useCase: MogakEditingUseCase) {
        self.useCase = useCase
    }

    func prepare(mode: MG2MogakFormMode) {
        switch mode {
        case .create:
            state = MG2MogakFormState()
        case .edit(let mogak):
            state = MG2MogakFormState(
                title: mogak.title,
                bigCategory: mogak.bigCategoryName,
                customCategory: mogak.smallCategory,
                color: String((mogak.color ?? DesignSystemPalette.signatureHex).suffix(6))
            )
        }
    }

    func updateTitle(_ title: String) {
        state.title = title
    }

    func updateCustomCategory(_ category: String?) {
        state.customCategory = category
    }

    func selectCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        state.bigCategory = categories[index]
    }

    func selectColor(at index: Int) {
        guard colors.indices.contains(index) else { return }
        state.color = colors[index]
    }

    var isValid: Bool {
        guard !trimmed(state.title).isEmpty,
              !state.bigCategory.isEmpty else { return false }
        return state.bigCategory != Self.customCategoryTitle
            || !trimmed(state.customCategory ?? "").isEmpty
    }

    var isCustomCategorySelected: Bool {
        state.bigCategory == Self.customCategoryTitle
    }

    func submit(
        mode: MG2MogakFormMode,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let input = state
        Task {
            do {
                let smallCategory = resolvedSmallCategory(
                    bigCategory: input.bigCategory,
                    customCategory: input.customCategory
                )
                switch mode {
                case .create(let modalartID):
                    try await useCase.createMogak(
                        modaratId: modalartID,
                        title: trimmed(input.title),
                        bigCategory: input.bigCategory,
                        smallCategory: smallCategory,
                        color: "#" + input.color
                    )
                case .edit(let mogak):
                    try await useCase.editMogak(
                        mogakId: mogak.mogakId,
                        title: trimmed(input.title),
                        bigCategory: input.bigCategory,
                        smallCategory: smallCategory,
                        color: "#" + input.color
                    )
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func resolvedSmallCategory(
        bigCategory: String,
        customCategory: String?
    ) -> String? {
        guard bigCategory == Self.customCategoryTitle else { return nil }
        let category = trimmed(customCategory ?? "")
        return category.isEmpty ? nil : category
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
