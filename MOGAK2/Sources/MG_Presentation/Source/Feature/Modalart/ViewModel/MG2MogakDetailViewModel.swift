import Foundation

struct MG2JogakSummaryViewData {
    let category: String
    let categoryColor: String
    let title: String
    let isRoutine: Bool
    let routineDaysText: String
    let periodText: String
}

struct MG2JogakActionContext {
    let detail: MG2JogakDetailEntity
    let summary: MG2JogakSummaryViewData
}

struct MG2MogakDetailViewState {
    var mogaks: [MG2ModalartMogakItemEntity]
    var selectedMogakID: Int
    var occurrences: [MG2JogakOccurrenceEntity]
    var routineDaysTextByJogakID: [Int: String]

    var selectedMogak: MG2ModalartMogakItemEntity? {
        mogaks.first { $0.mogakId == selectedMogakID }
    }
}

enum MG2MogakDeletionResult {
    case reloaded
    case noMogaksRemaining
}

@MainActor
final class MG2MogakDetailViewModel {
    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()

    private let useCase: ModalartUseCase
    private let scheduleUseCase: ScheduleStartUseCase
    private let modalartID: Int
    private(set) var state: MG2MogakDetailViewState

    init(
        useCase: ModalartUseCase,
        scheduleUseCase: ScheduleStartUseCase,
        modalartID: Int,
        mogaks: [MG2ModalartMogakItemEntity],
        selectedMogak: MG2ModalartMogakItemEntity,
        occurrences: [MG2JogakOccurrenceEntity]
    ) {
        self.useCase = useCase
        self.scheduleUseCase = scheduleUseCase
        self.modalartID = modalartID
        state = MG2MogakDetailViewState(
            mogaks: mogaks,
            selectedMogakID: selectedMogak.mogakId,
            occurrences: occurrences,
            routineDaysTextByJogakID: [:]
        )
    }

    var hasRoutineOccurrences: Bool {
        state.occurrences.contains { $0.isRoutine }
    }

    func loadRoutineDays(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                state.routineDaysTextByJogakID = try await loadRoutineDaysText(
                    for: state.occurrences
                )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func selectMogak(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard state.mogaks.indices.contains(index) else { return }
        state.selectedMogakID = state.mogaks[index].mogakId
        reloadOccurrences(completion: completion)
    }

    func reloadOccurrences(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedMogak = state.selectedMogak else { return }
        Task {
            do {
                try await reloadOccurrences(mogakID: selectedMogak.mogakId)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func reloadMogaks(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await reloadMogaksAndOccurrences()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteSelectedMogak(
        completion: @escaping (Result<MG2MogakDeletionResult, Error>) -> Void
    ) {
        guard let selectedMogak = state.selectedMogak else { return }
        Task {
            do {
                try await useCase.deleteMogak(mogakId: selectedMogak.mogakId)
                try await reloadMogaksAndOccurrences()
                completion(.success(state.mogaks.isEmpty ? .noMogaksRemaining : .reloaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteJogak(
        id: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await useCase.deleteJogak(jogakId: id)
                guard let selectedMogak = state.selectedMogak else { return }
                try await reloadOccurrences(mogakID: selectedMogak.mogakId)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func routineDaysText(for occurrence: MG2JogakOccurrenceEntity) -> String {
        state.routineDaysTextByJogakID[occurrence.key.jogakID] ?? "0회"
    }

    func loadJogakActionContext(
        for occurrence: MG2JogakOccurrenceEntity,
        completion: @escaping (Result<MG2JogakActionContext, Error>) -> Void
    ) {
        Task {
            do {
                let detail = try await scheduleUseCase.getJogakDetail(
                    jogakId: occurrence.key.jogakID
                )
                completion(.success(makeActionContext(detail: detail)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func reloadMogaksAndOccurrences() async throws {
        let previousSelection = state.selectedMogakID
        state.mogaks = try await useCase.getModalartMogakPage(modalartId: modalartID)?.items ?? []
        guard !state.mogaks.isEmpty else {
            state.occurrences = []
            state.routineDaysTextByJogakID = [:]
            return
        }

        let selection = state.mogaks.first { $0.mogakId == previousSelection } ?? state.mogaks[0]
        state.selectedMogakID = selection.mogakId
        try await reloadOccurrences(mogakID: selection.mogakId)
    }

    private func reloadOccurrences(mogakID: Int) async throws {
        let occurrences = try await useCase.getMogakOverview(
            mogakId: mogakID,
            from: Date()
        )
        let routineDaysText = try await loadRoutineDaysText(for: occurrences)
        state.occurrences = occurrences
        state.routineDaysTextByJogakID = routineDaysText
    }

    private func loadRoutineDaysText(
        for occurrences: [MG2JogakOccurrenceEntity]
    ) async throws -> [Int: String] {
        var result = [Int: String]()
        for occurrence in occurrences where occurrence.isRoutine {
            let detail = try await scheduleUseCase.getJogakDetail(
                jogakId: occurrence.key.jogakID
            )
            let days = localizedDays(from: detail.days)
            result[occurrence.key.jogakID] = days.isEmpty
                ? "0회"
                : days.joined(separator: ",")
        }
        return result
    }

    private func makeActionContext(detail: MG2JogakDetailEntity) -> MG2JogakActionContext {
        let days = localizedDays(from: detail.days)
        let summary = MG2JogakSummaryViewData(
            category: detail.category.name,
            categoryColor: detail.color ?? DesignSystemPalette.signatureHex,
            title: detail.title,
            isRoutine: detail.isRoutine,
            routineDaysText: days.isEmpty ? "미지정" : days.joined(separator: ","),
            periodText: periodText(startDate: detail.startDate, endDate: detail.endDate)
        )
        return MG2JogakActionContext(detail: detail, summary: summary)
    }

    private func localizedDays(from days: [MG2Weekday]) -> [String] {
        days.sorted { $0.rawValue < $1.rawValue }.map(\.shortKoreanTitle)
    }

    private func periodText(startDate: Date?, endDate: Date?) -> String {
        guard let startDate else { return "미지정" }
        let startText = Self.displayDateFormatter.string(from: startDate)
        guard let endDate else { return startText }
        return "\(startText) ~ \(Self.displayDateFormatter.string(from: endDate))"
    }
}
