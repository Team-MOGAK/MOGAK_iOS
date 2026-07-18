import Foundation

struct MG2ModalartTitleEditorState {
    var title: String
    var selectedColor: String?

    var canSubmit: Bool {
        selectedColor != nil
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && title.count <= 20
    }
}

@MainActor
final class MG2ModalartTitleEditorViewModel {
    let colors = DesignSystemPalette.modalartColors

    private(set) var state: MG2ModalartTitleEditorState

    init(title: String?, color: String) {
        let normalizedColor = String(color.suffix(6)).uppercased()
        state = MG2ModalartTitleEditorState(
            title: title ?? "",
            selectedColor: colors.contains(normalizedColor) ? normalizedColor : nil
        )
    }

    var selectedColorIndex: Int? {
        guard let selectedColor = state.selectedColor else { return nil }
        return colors.firstIndex(of: selectedColor)
    }

    func canUpdateTitle(_ title: String) -> Bool {
        title.count <= 20
    }

    func updateTitle(_ title: String) {
        state.title = title
    }

    func selectColor(at index: Int) {
        guard colors.indices.contains(index) else { return }
        state.selectedColor = colors[index]
    }

    func submission() -> (title: String, color: String)? {
        guard state.canSubmit, let selectedColor = state.selectedColor else { return nil }
        return (state.title, "#" + selectedColor)
    }
}
