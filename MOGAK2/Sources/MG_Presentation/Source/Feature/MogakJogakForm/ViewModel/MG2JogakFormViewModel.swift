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
}

@MainActor
final class MG2JogakFormViewModel {
    let routineDays = MG2Weekday.allCases.map(\.shortKoreanTitle)

    private let useCase: MogakEditingUseCase
    private(set) var state = MG2JogakFormState()
    private var originalScheduleState: ScheduleState?

    private struct ScheduleState: Equatable {
        let isRoutine: Bool
        let selectedDayIndices: Set<Int>
        let endDate: Date?
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy/M/d(EEE)"
        return formatter
    }()

    init(useCase: MogakEditingUseCase) {
        self.useCase = useCase
    }

    func prepare(mode: MG2JogakFormMode) {
        let today = Date()
        switch mode {
        case .create(let mogak):
            originalScheduleState = nil
            state = MG2JogakFormState(
                category: mogak.category.name,
                categoryColor: String((mogak.color ?? DesignSystemPalette.signatureHex).suffix(6)),
                today: today
            )
        case .edit(let jogak):
            let endDate = jogak.endDate
            let selectedDayIndices = Set(jogak.days.map(\.rawValue))
            state = MG2JogakFormState(
                title: jogak.title,
                category: jogak.category.name,
                categoryColor: String((jogak.color ?? DesignSystemPalette.signatureHex).suffix(6)),
                isRoutine: jogak.isRoutine,
                selectedRoutineDayIndices: selectedDayIndices,
                today: today,
                endDate: endDate
            )
            originalScheduleState = ScheduleState(
                isRoutine: jogak.isRoutine,
                selectedDayIndices: selectedDayIndices,
                endDate: endDate
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
    }

    var isValid: Bool {
        guard !trimmed(state.title).isEmpty else { return false }
        return !state.isRoutine || !state.selectedRoutineDayIndices.isEmpty
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
                    : []
                let schedule = makeSchedule(input: input, weekdays: weekdays)
                switch mode {
                case .create(let mogak):
                    try await useCase.createJogak(
                        mogakId: mogak.mogakId,
                        title: trimmed(input.title),
                        schedule: schedule
                    )
                case .edit(let jogak):
                    let currentScheduleState = ScheduleState(
                        isRoutine: input.isRoutine,
                        selectedDayIndices: input.selectedRoutineDayIndices,
                        endDate: input.isRoutine ? input.endDate : nil
                    )
                    try await useCase.editJogak(
                        jogakId: jogak.jogakID,
                        title: trimmed(input.title),
                        schedule: currentScheduleState == originalScheduleState ? nil : schedule
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

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeSchedule(
        input: MG2JogakFormState,
        weekdays: [MG2Weekday]
    ) -> MG2JogakSchedule {
        if input.isRoutine {
            return .weekly(
                effectiveFrom: input.today,
                effectiveTo: input.endDate,
                weekdays: weekdays
            )
        }
        return .once(effectiveFrom: input.today)
    }
}
