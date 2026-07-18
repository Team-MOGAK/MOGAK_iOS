import Foundation

private enum MG2ModalartDefaults {
    static let titlePrefix = "내 모다라트"
}

struct MG2ModalartViewState {
    var modalarts = [MG2ModalartListItemEntity]()
    var selectedIndex = 0
    var selectedID: Int?
    var title = ""
    var color = DesignSystemPalette.neutralGrayHex
    var mogaks = [MG2ModalartMogakItemEntity]()

    var hasModalart: Bool { selectedID != nil }
    var needsTitle: Bool {
        guard title.hasPrefix(MG2ModalartDefaults.titlePrefix) else { return false }
        return Int(title.dropFirst(MG2ModalartDefaults.titlePrefix.count)) != nil
    }
    var centerTitle: String { needsTitle ? "큰 목표 \n추가" : title }
    var centerColor: String {
        needsTitle ? DesignSystemPalette.neutralGrayHex : color
    }
}

@MainActor
final class MG2ModalartViewModel {
    private let useCase: ModalartUseCase
    private let userState: MG2UserState

    private(set) var state = MG2ModalartViewState()

    init(useCase: ModalartUseCase, userState: MG2UserState) {
        self.useCase = useCase
        self.userState = userState
    }

    var isGuest: Bool { userState.loginState == .guest }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        if isGuest {
            state = MG2ModalartViewState(
                modalarts: [],
                selectedIndex: 0,
                selectedID: nil,
                title: "2024",
                color: DesignSystemPalette.signatureHex,
                mogaks: guestMogaks
            )
            completion(.success(()))
            return
        }

        Task {
            do {
                try await reloadSelectingFirst()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func selectModalart(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard state.modalarts.indices.contains(index) else { return }
        let modalart = state.modalarts[index]
        Task {
            do {
                try await loadSelection(id: modalart.id, index: index)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func createModalart(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await createDefaultModalart()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateSelectedModalart(
        title: String,
        color: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let selectedID = state.selectedID else { return }
        Task {
            do {
                let updated = try await useCase.editModalart(
                    id: selectedID,
                    title: title,
                    color: color
                )
                state.title = updated.title
                state.color = updated.color
                if state.modalarts.indices.contains(state.selectedIndex) {
                    state.modalarts[state.selectedIndex] = MG2ModalartListItemEntity(
                        id: updated.id,
                        title: updated.title,
                        color: updated.color
                    )
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteSelectedModalart(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedID = state.selectedID else { return }
        Task {
            do {
                try await useCase.deleteModalart(id: selectedID)
                try await reloadSelectingFirst()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func reloadSelectedModalart(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedID = state.selectedID else { return }
        let selectedIndex = state.selectedIndex
        Task {
            do {
                try await loadSelection(id: selectedID, index: selectedIndex)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func loadJogaks(
        for mogak: MG2ModalartMogakItemEntity,
        completion: @escaping (Result<[MG2JogakDetailEntity], Error>) -> Void
    ) {
        Task {
            do {
                let jogaks = try await useCase.getMogakDetailJogaks(
                    mogakId: mogak.mogakId,
                    date: Date()
                )
                completion(.success(jogaks))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func reloadSelectingFirst() async throws {
        state.modalarts = try await useCase.getModalartList()
        guard let first = state.modalarts.first else {
            try await createDefaultModalart()
            return
        }
        try await loadSelection(id: first.id, index: 0)
    }

    private func loadSelection(id: Int, index: Int) async throws {
        async let detail = useCase.getModalartDetail(modalartId: id)
        async let page = useCase.getModalartMogakPage(modalartId: id)
        let (modalart, mogakPage) = try await (detail, page)

        state.selectedID = id
        state.selectedIndex = index
        state.title = modalart?.title ?? state.modalarts[index].title
        state.color = modalart?.color ?? DesignSystemPalette.neutralGrayHex
        state.mogaks = mogakPage?.items ?? []
    }

    private func createDefaultModalart() async throws {
        let sequence = nextDefaultTitleSequence()
        let created = try await useCase.createModalart(
            title: MG2ModalartDefaults.titlePrefix + String(sequence),
            color: DesignSystemPalette.neutralGrayHex
        )
        state.modalarts.append(
            MG2ModalartListItemEntity(
                id: created.id,
                title: created.title,
                color: created.color
            )
        )
        state.selectedIndex = state.modalarts.count - 1
        state.selectedID = created.id
        state.title = created.title
        state.color = created.color
        state.mogaks = []
    }

    private func nextDefaultTitleSequence() -> Int {
        let usedSequences = state.modalarts.compactMap { modalart -> Int? in
            guard modalart.title.hasPrefix(MG2ModalartDefaults.titlePrefix) else {
                return nil
            }
            return Int(modalart.title.dropFirst(MG2ModalartDefaults.titlePrefix.count))
        }
        return (usedSequences.max() ?? 0) + 1
    }

    private var guestMogaks: [MG2ModalartMogakItemEntity] {
        [
            makeGuestMogak(title: "다이어트", category: "운동", color: "11D796"),
            makeGuestMogak(title: "정보처리기사 취득", category: "자격증", color: "FF4C77"),
            makeGuestMogak(title: "영어공부", category: "어학", color: "FF2323"),
            makeGuestMogak(title: "Swift 문법", category: "스터디", color: "21CAFF"),
            makeGuestMogak(title: "스페인어 공부", category: "어학", color: "F98A08")
        ]
    }

    private func makeGuestMogak(
        title: String,
        category: String,
        color: String
    ) -> MG2ModalartMogakItemEntity {
        MG2ModalartMogakItemEntity(
            mogakId: 0,
            title: title,
            bigCategoryId: 0,
            bigCategoryName: category,
            smallCategory: nil,
            color: color
        )
    }
}
