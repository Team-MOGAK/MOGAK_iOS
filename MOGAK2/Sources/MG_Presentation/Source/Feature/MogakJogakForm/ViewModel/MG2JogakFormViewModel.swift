import Foundation

enum MG2JogakFormMode {
    case create(MG2ModalartMogakItemEntity)
    case edit(MG2JogakDetailEntity)
}

struct MG2JogakFormState {
    var title = ""
    var category = ""
    var categoryColor = DesignSystemPalette.signatureHex
    var isRoutine = false
    var selectedRoutineDayIndices = Set<Int>()
    var today = Date()
    var endDate: Date?
    var currentCalendarPage = Date()
}

@MainActor
final class MG2JogakFormViewModel {
    let routineDays = MG2Weekday.allCases.map(\.shortKoreanTitle)

    private let useCase: MogakEditingUseCase
    private(set) var state = MG2JogakFormState()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy/M/d(EEE)"
        return formatter
    }()

    private static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    init(useCase: MogakEditingUseCase) {
        self.useCase = useCase
    }

    func prepare(mode: MG2JogakFormMode) {
        let today = Date()
        switch mode {
        case .create(let mogak):
            state = MG2JogakFormState(
                category: mogak.bigCategoryName,
                categoryColor: String((mogak.color ?? DesignSystemPalette.signatureHex).suffix(6)),
                today: today,
                currentCalendarPage: today
            )
        case .edit(let jogak):
            let endDate = jogak.endDate
            state = MG2JogakFormState(
                title: jogak.title,
                category: jogak.category,
                categoryColor: String((jogak.color ?? DesignSystemPalette.signatureHex).suffix(6)),
                isRoutine: jogak.isRoutine,
                selectedRoutineDayIndices: Set(jogak.days.map(\.rawValue)),
                today: today,
                endDate: endDate,
                currentCalendarPage: endDate ?? today
            )
        }
    }

    func updateTitle(_ title: String) {
        state.title = title
    }

    func setRoutine(_ isRoutine: Bool) {
        state.isRoutine = isRoutine
    }

    func setRoutineDay(at index: Int, isSelected: Bool) {
        guard routineDays.indices.contains(index) else { return }
        if isSelected {
            state.selectedRoutineDayIndices.insert(index)
        } else {
            state.selectedRoutineDayIndices.remove(index)
        }
    }

    func selectEndDate(_ date: Date) {
        state.endDate = date
        state.currentCalendarPage = date
    }

    func updateCalendarPage(_ date: Date) {
        state.currentCalendarPage = date
    }

    func moveCalendarPage(by monthOffset: Int) -> Date? {
        guard let page = Calendar(identifier: .gregorian).date(
            byAdding: .month,
            value: monthOffset,
            to: state.currentCalendarPage
        ) else { return nil }
        state.currentCalendarPage = page
        return page
    }

    var isValid: Bool {
        guard !trimmed(state.title).isEmpty else { return false }
        return !state.isRoutine
            || (!state.selectedRoutineDayIndices.isEmpty && state.endDate != nil)
    }

    func submit(
        mode: MG2JogakFormMode,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let input = state
        Task {
            do {
                let weekdays = input.isRoutine
                    ? input.selectedRoutineDayIndices.sorted().compactMap(MG2Weekday.init(rawValue:))
                    : nil
                let endDate = input.isRoutine ? input.endDate : nil
                switch mode {
                case .create(let mogak):
                    try await useCase.createJogak(
                        mogakId: mogak.mogakId,
                        title: trimmed(input.title),
                        isRoutine: input.isRoutine,
                        days: weekdays,
                        today: input.today,
                        endDate: endDate
                    )
                case .edit(let jogak):
                    try await useCase.editJogak(
                        jogakId: jogak.jogakID,
                        title: trimmed(input.title),
                        isRoutine: input.isRoutine,
                        days: weekdays,
                        endDate: endDate
                    )
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func displayDate(_ date: Date) -> String {
        Self.displayDateFormatter.string(from: date)
    }

    func monthTitle(for date: Date) -> String {
        Self.monthTitleFormatter.string(from: date)
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
