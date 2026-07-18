import Foundation

struct MG2JogakSummaryViewData {
    let category: String
    let categoryColor: String
    let title: String
    let isRoutine: Bool
    let routineDaysText: String
    let periodText: String
}

struct MG2MogakDetailViewState {
    var mogaks: [MG2ModalartMogakItemEntity]
    var selectedMogakID: Int
    var jogaks: [MG2JogakDetailEntity]

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
    private let modalartID: Int
    private(set) var state: MG2MogakDetailViewState

    init(
        useCase: ModalartUseCase,
        modalartID: Int,
        mogaks: [MG2ModalartMogakItemEntity],
        selectedMogak: MG2ModalartMogakItemEntity,
        jogaks: [MG2JogakDetailEntity]
    ) {
        self.useCase = useCase
        self.modalartID = modalartID
        state = MG2MogakDetailViewState(
            mogaks: mogaks,
            selectedMogakID: selectedMogak.mogakId,
            jogaks: jogaks
        )
    }

    func selectMogak(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard state.mogaks.indices.contains(index) else { return }
        state.selectedMogakID = state.mogaks[index].mogakId
        reloadJogaks(completion: completion)
    }

    func reloadJogaks(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedMogak = state.selectedMogak else { return }
        Task {
            do {
                state.jogaks = try await useCase.getMogakDetailJogaks(
                    mogakId: selectedMogak.mogakId,
                    date: Date()
                )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func reloadMogaks(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await reloadMogaksAndJogaks()
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
                try await reloadMogaksAndJogaks()
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
                state.jogaks = try await useCase.getMogakDetailJogaks(
                    mogakId: selectedMogak.mogakId,
                    date: Date()
                )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func jogakCellDaysText(for jogak: MG2JogakDetailEntity) -> String {
        let days = localizedDays(from: jogak.days)
        return days.isEmpty ? "0회" : days.joined(separator: ",")
    }

    func makeJogakSummary(for jogak: MG2JogakDetailEntity) -> MG2JogakSummaryViewData? {
        guard let selectedMogak = state.selectedMogak else { return nil }
        let days = localizedDays(from: jogak.days)
        return MG2JogakSummaryViewData(
            category: selectedMogak.bigCategoryName,
            categoryColor: selectedMogak.color ?? DesignSystemPalette.signatureHex,
            title: jogak.title,
            isRoutine: jogak.isRoutine,
            routineDaysText: days.isEmpty ? "미지정" : days.joined(separator: ","),
            periodText: periodText(startDate: jogak.startDate, endDate: jogak.endDate)
        )
    }

    private func reloadMogaksAndJogaks() async throws {
        let previousSelection = state.selectedMogakID
        state.mogaks = try await useCase.getModalartMogakPage(modalartId: modalartID)?.items ?? []
        guard !state.mogaks.isEmpty else {
            state.jogaks = []
            return
        }

        let selection = state.mogaks.first { $0.mogakId == previousSelection } ?? state.mogaks[0]
        state.selectedMogakID = selection.mogakId
        state.jogaks = try await useCase.getMogakDetailJogaks(
            mogakId: selection.mogakId,
            date: Date()
        )
    }

    private func localizedDays(from days: [MG2Weekday]) -> [String] {
        days.sorted { $0.rawValue < $1.rawValue }.map(\.shortKoreanTitle)
    }

    private func periodText(startDate: Date?, endDate: Date?) -> String {
        guard let startDate,
              let endDate else {
            return "미지정"
        }
        return "\(Self.displayDateFormatter.string(from: startDate)) ~ \(Self.displayDateFormatter.string(from: endDate))"
    }
}
