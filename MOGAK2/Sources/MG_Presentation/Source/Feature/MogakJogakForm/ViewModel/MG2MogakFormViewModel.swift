import Foundation

enum MG2MogakFormMode {
    case create(modalartID: Int)
    case edit(MG2ModalartMogakItemEntity)
}

struct MG2MogakFormState {
    var title = ""
    var selectedCategoryCode: String?
    var customCategory: String?
    var isCustomCategorySelected = false
    var color = DesignSystemPalette.signatureHex
}

@MainActor
final class MG2MogakFormViewModel {
    private static let customCategoryCode = "OTHER"

    let colors = DesignSystemPalette.mogakColors
    private(set) var categories = [MG2MogakCategoryEntity]()

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
                selectedCategoryCode: mogak.category.code,
                customCategory: mogak.category.code == nil ? mogak.category.name : nil,
                isCustomCategorySelected: mogak.category.code == nil,
                color: String((mogak.color ?? DesignSystemPalette.signatureHex).suffix(6))
            )
        }
    }

    func loadCategories(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                categories = try await useCase.getMogakCategories()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
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
        let category = categories[index]
        state.isCustomCategorySelected = category.code == Self.customCategoryCode
        state.selectedCategoryCode = state.isCustomCategorySelected ? nil : category.code
    }

    func selectColor(at index: Int) {
        guard colors.indices.contains(index) else { return }
        state.color = colors[index]
    }

    var isValid: Bool {
        guard !trimmed(state.title).isEmpty else { return false }
        if state.isCustomCategorySelected {
            return !trimmed(state.customCategory ?? "").isEmpty
        }
        return state.selectedCategoryCode != nil
    }

    var selectedCategoryIndex: Int? {
        if state.isCustomCategorySelected {
            return categories.firstIndex { $0.code == Self.customCategoryCode }
        }
        return categories.firstIndex { $0.code == state.selectedCategoryCode }
    }

    var isCustomCategorySelected: Bool {
        state.isCustomCategorySelected
    }

    func submit(
        mode: MG2MogakFormMode,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let input = state
        let category: MG2MogakCategorySelection
        if input.isCustomCategorySelected {
            category = .custom(name: trimmed(input.customCategory ?? ""))
        } else if let code = input.selectedCategoryCode {
            category = .official(code: code)
        } else {
            return
        }

        Task {
            do {
                switch mode {
                case .create(let modalartID):
                    try await useCase.createMogak(
                        modaratId: modalartID,
                        title: trimmed(input.title),
                        category: category,
                        color: "#" + input.color
                    )
                case .edit(let mogak):
                    try await useCase.editMogak(
                        mogakId: mogak.mogakId,
                        title: trimmed(input.title),
                        category: category,
                        color: "#" + input.color
                    )
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
