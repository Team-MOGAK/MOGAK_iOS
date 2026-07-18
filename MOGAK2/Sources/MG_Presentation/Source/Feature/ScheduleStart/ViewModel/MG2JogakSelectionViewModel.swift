import Foundation

struct MG2ModalartOption {
    let id: Int
    let title: String
    let color: String
}

struct MG2JogakSelectionItem {
    let id: Int
    let title: String
    var isAlreadyAdded: Bool
    let isRoutine: Bool

    var isSelectable: Bool {
        !isAlreadyAdded && !isRoutine
    }
}

struct MG2MogakJogakSection {
    let title: String
    let color: String
    var jogaks: [MG2JogakSelectionItem]
}

struct MG2JogakSelectionViewState {
    var modalarts = [MG2ModalartOption]()
    var selectedModalartID: Int?
    var sections = [MG2MogakJogakSection]()

    var selectedModalart: MG2ModalartOption? {
        modalarts.first { $0.id == selectedModalartID }
    }
}

@MainActor
final class MG2JogakSelectionViewModel {
    private let modalartUseCase: ModalartUseCase
    private let scheduleUseCase: ScheduleStartUseCase
    private var selectedJogakIDs = Set<Int>()

    private(set) var state = MG2JogakSelectionViewState()

    init(modalartUseCase: ModalartUseCase, scheduleUseCase: ScheduleStartUseCase) {
        self.modalartUseCase = modalartUseCase
        self.scheduleUseCase = scheduleUseCase
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

    func loadModalarts(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                state.modalarts = try await modalartUseCase.getModalartList().map {
                    MG2ModalartOption(id: $0.id, title: $0.title, color: $0.color)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func loadMogakSections(
        modalartID: Int,
        date: Date = Date(),
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                let page = try await modalartUseCase.getModalartMogakPage(
                    modalartId: modalartID
                ) ?? MG2ModalartMogakPageEntity(items: [], size: 0)
                var sections = [MG2MogakJogakSection]()
                sections.reserveCapacity(page.items.count)

                for mogak in page.items {
                    let jogaks = try await modalartUseCase.getMogakDetailJogaks(
                        mogakId: mogak.mogakId,
                        date: date
                    )
                    sections.append(
                        MG2MogakJogakSection(
                            title: mogak.title,
                            color: mogak.color ?? "",
                            jogaks: jogaks.map {
                                MG2JogakSelectionItem(
                                    id: $0.jogakID,
                                    title: $0.title,
                                    isAlreadyAdded: $0.isAlreadyAdded ?? false,
                                    isRoutine: $0.isRoutine
                                )
                            }
                        )
                    )
                }

                state.selectedModalartID = modalartID
                state.sections = sections
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
                    try await scheduleUseCase.addJogakDaily(jogakId: jogakID)
                    selectedJogakIDs.remove(jogakID)
                    markJogakAsAdded(jogakID)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func markJogakAsAdded(_ jogakID: Int) {
        for sectionIndex in state.sections.indices {
            guard let itemIndex = state.sections[sectionIndex].jogaks.firstIndex(
                where: { $0.id == jogakID }
            ) else { continue }
            state.sections[sectionIndex].jogaks[itemIndex].isAlreadyAdded = true
            return
        }
    }
}
