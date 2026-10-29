import Foundation

struct MG2ModalartMainViewState {
    var modalarts = [MG2ModalartListItemEntity]()
    var selectedIndex = 0
    var selectedID: Int?
    var title = ""
    var color = DesignSystemPalette.neutralGrayHex
    var mogaks = [MG2ModalartMogakItemEntity]()

    var hasModalart: Bool { selectedID != nil }
    var needsTitle: Bool { MG2ModalartDefaultTitle.isDefault(title) }
    var centerTitle: String { needsTitle ? "최종 목표\n정하기" : title }
    var centerColor: String {
        needsTitle ? DesignSystemPalette.neutralGrayHex : color
    }
}

@MainActor
final class MG2ModalartMainViewModel {
    private let useCase: ModalartUseCase
    private let userState: MG2UserState

    private(set) var state = MG2ModalartMainViewState()
    /// 마지막으로 부른 판. 기다리는 사이 다른 판을 고르면 앞 응답은 버린다.
    private var latestSelectionRequest = 0

    init(useCase: ModalartUseCase, userState: MG2UserState) {
        self.useCase = useCase
        self.userState = userState
    }

    var isGuest: Bool { userState.loginState == .guest }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        if isGuest {
            state = MG2ModalartMainViewState(modalarts: [], selectedIndex: 0, selectedID: nil, title: "2024", color: DesignSystemPalette.signatureHex, mogaks: guestMogaks)
            completion(.success(()))
            return
        }

        Task {
            do {
                try await reloadSelectingFirst()
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    func selectModalart(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard state.modalarts.indices.contains(index) else { return completion(.success(())) }
        let modalart = state.modalarts[index]
        Task {
            do {
                try await loadSelection(id: modalart.id, index: index)
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
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
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateSelectedModalart(title: String, color: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedID = state.selectedID else { return completion(.success(())) }
        Task {
            do {
                let updated = try await useCase.editModalart(id: selectedID, title: title, color: color)
                // 기다리는 사이 다른 판으로 바꿨을 수 있으니 고친 판을 id로 찾아 바꾼다.
                if let index = state.modalarts.firstIndex(where: { $0.id == updated.id }) {
                    state.modalarts[index] = MG2ModalartListItemEntity(id: updated.id, title: updated.title, color: updated.color)
                }
                if state.selectedID == selectedID {
                    state.title = updated.title
                    state.color = updated.color
                }
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteSelectedModalart(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedID = state.selectedID else { return completion(.success(())) }
        Task {
            do {
                try await useCase.deleteModalart(id: selectedID)
                try await reloadSelectingFirst()
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    func reloadSelectedModalart(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedID = state.selectedID else { return completion(.success(())) }
        let selectedIndex = state.selectedIndex
        Task {
            do {
                try await loadSelection(id: selectedID, index: selectedIndex)
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 판의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func reloadSelectingFirst() async throws {
        state.modalarts = try await useCase.loadModalarts()
        guard let first = state.modalarts.first else { return }
        try await loadSelection(id: first.id, index: 0)
    }

    private func loadSelection(id: Int, index: Int) async throws {
        latestSelectionRequest += 1
        let request = latestSelectionRequest
        async let detail = useCase.getModalartDetail(modalartId: id)
        async let mogaks = useCase.getModalartMogaks(modalartId: id)
        let (modalart, loadedMogaks) = try await (detail, mogaks)
        guard request == latestSelectionRequest else { throw CancellationError() }

        state.selectedID = id
        state.selectedIndex = index
        state.title = modalart?.title ?? state.modalarts.first { $0.id == id }?.title ?? state.title
        state.color = modalart?.color ?? DesignSystemPalette.neutralGrayHex
        state.mogaks = loadedMogaks
    }

    private func createDefaultModalart() async throws {
        let created = try await useCase.createDefaultModalart(existing: state.modalarts)
        state.modalarts.append(created)
        state.selectedIndex = state.modalarts.count - 1
        state.selectedID = created.id
        state.title = created.title
        state.color = created.color
        state.mogaks = []
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

    /// 모각 만들기 화면 위 경로: 판 › 모각 n/8.
    var mogakCreationPath: [MG2PathItem] {
        [MG2PathItem(label: state.title), MG2PathItem(label: "모각 \(state.mogaks.count + 1)/8")]
    }

    func mogakPath(for mogak: MG2ModalartMogakItemEntity) -> [MG2PathItem] {
        [MG2PathItem(label: state.title), MG2PathItem(label: mogak.title, colorHex: mogak.color)]
    }

    private func makeGuestMogak(title: String, category: String, color: String) -> MG2ModalartMogakItemEntity {
        MG2ModalartMogakItemEntity(mogakId: 0, title: title, category: MG2MogakCategoryEntity(code: nil, name: category), color: color)
    }
}
