import Foundation

struct MG2JogakSelectionItem {
    let id: Int
    let title: String
    var status: MG2JogakOccurrenceStatus
    let isRoutine: Bool

    var isSelectable: Bool {
        status == .pending
    }
}

struct MG2MogakJogakSection {
    let title: String
    let color: String
    var jogaks: [MG2JogakSelectionItem]
}

@MainActor
final class MG2SelectJogakViewModel {
    let modalarts: [MG2ModalartOption]
    let initialModalart: MG2ModalartOption
    private let useCase: ScheduleStartUseCase
    private let scheduledDate: Date
    private var selectedJogakIDs = Set<Int>()
    private(set) var selectedModalartID: Int?
    private(set) var sections = [MG2MogakJogakSection]()

    init(useCase: ScheduleStartUseCase, scheduledDate: Date, modalarts: [MG2ModalartOption], initialModalart: MG2ModalartOption) {
        self.useCase = useCase
        self.scheduledDate = scheduledDate
        self.modalarts = modalarts
        self.initialModalart = initialModalart
    }

    var selectedModalart: MG2ModalartOption? {
        modalarts.first { $0.id == selectedModalartID }
    }

    var hasSelectedJogaks: Bool { !selectedJogakIDs.isEmpty }

    func isJogakSelected(_ jogakID: Int) -> Bool {
        selectedJogakIDs.contains(jogakID)
    }

    @discardableResult
    func toggleJogakSelection(_ jogakID: Int) -> Bool {
        if selectedJogakIDs.remove(jogakID) != nil {
            return false
        }
        selectedJogakIDs.insert(jogakID)
        return true
    }

    func loadMogakSections(modalartID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let mogakOccurrences = try await useCase.getMogakOccurrences(modalartId: modalartID, date: scheduledDate)
                selectedModalartID = modalartID
                sections = mogakOccurrences.map { item in MG2MogakJogakSection(title: item.mogak.title, color: item.mogak.color ?? "", jogaks: item.occurrences.map { MG2JogakSelectionItem(id: $0.key.jogakID, title: $0.title, status: $0.status, isRoutine: $0.isRoutine) }) }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func addSelectedJogaks(completion: @escaping (Result<Void, Error>) -> Void) {
        let jogakIDs = selectedJogakIDs.sorted()
        Task {
            do {
                for jogakID in jogakIDs {
                    try await useCase.startJogak(jogakId: jogakID, scheduledDate: scheduledDate)
                    selectedJogakIDs.remove(jogakID)
                    markJogakAsStarted(jogakID)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func markJogakAsStarted(_ jogakID: Int) {
        for sectionIndex in sections.indices {
            guard let itemIndex = sections[sectionIndex].jogaks.firstIndex(where: { $0.id == jogakID }) else { continue }
            sections[sectionIndex].jogaks[itemIndex].status = .inProgress
            return
        }
    }
}
