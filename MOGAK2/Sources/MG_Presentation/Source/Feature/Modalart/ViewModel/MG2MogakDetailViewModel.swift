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
    var jogaks: [MG2MogakJogakEntity]

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
    private let modalartTitle: String
    private(set) var state: MG2MogakDetailViewState

    init(useCase: ModalartUseCase, modalartID: Int, modalartTitle: String, mogaks: [MG2ModalartMogakItemEntity], selectedMogak: MG2ModalartMogakItemEntity) {
        self.useCase = useCase
        self.modalartID = modalartID
        self.modalartTitle = modalartTitle
        state = MG2MogakDetailViewState(mogaks: mogaks, selectedMogakID: selectedMogak.mogakId, jogaks: [])
    }

    /// 만들기 · 수정 화면 위 경로: 판 › 모각.
    var mogakPath: [MG2PathItem] {
        guard let mogak = state.selectedMogak else { return [MG2PathItem(label: modalartTitle)] }
        return [MG2PathItem(label: modalartTitle), MG2PathItem(label: mogak.title, colorHex: mogak.color)]
    }

    /// 판 › 모각 › 조각 n/8.
    var jogakCreationPath: [MG2PathItem] {
        mogakPath + [MG2PathItem(label: "조각 \(state.jogaks.count + 1)/8")]
    }

    func selectMogak(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard state.mogaks.indices.contains(index) else { return completion(.success(())) }
        select(mogakID: state.mogaks[index].mogakId)
        reloadJogaks(completion: completion)
    }

    func reloadJogaks(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let mogakID = state.selectedMogak?.mogakId else { return completion(.success(())) }
        Task {
            do {
                try await reloadJogaks(mogakID: mogakID)
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

    func deleteSelectedMogak(completion: @escaping (Result<MG2MogakDeletionResult, Error>) -> Void) {
        guard let selectedMogak = state.selectedMogak else { return completion(.success(.reloaded)) }
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

    func deleteJogak(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await useCase.deleteJogak(jogakId: id)
                if let selectedMogak = state.selectedMogak {
                    try await reloadJogaks(mogakID: selectedMogak.mogakId)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func routineDaysText(for jogak: MG2MogakJogakEntity) -> String {
        let days = localizedDays(from: jogak.days)
        return days.isEmpty ? "0회" : days.joined(separator: ",")
    }

    func loadJogakActionContext(for jogak: MG2MogakJogakEntity, completion: @escaping (Result<MG2JogakActionContext, Error>) -> Void) {
        Task {
            do {
                let detail = try await useCase.getJogakDetail(jogakId: jogak.jogakID)
                completion(.success(makeActionContext(detail: detail)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func reloadMogaksAndJogaks() async throws {
        state.mogaks = try await useCase.getModalartMogaks(modalartId: modalartID)
        guard !state.mogaks.isEmpty else {
            state.jogaks = []
            return
        }

        // 기다리는 사이 다른 모각 칩을 눌렀을 수 있으니 지금 고른 모각을 기준으로 한다.
        let selection = state.mogaks.first { $0.mogakId == state.selectedMogakID } ?? state.mogaks[0]
        select(mogakID: selection.mogakId)
        try await reloadJogaks(mogakID: selection.mogakId)
    }

    /// 다른 모각으로 바꾸면 앞 모각의 조각을 비운다. 불러오다 실패해도 앞 모각 조각이 새 모각 아래 남지 않는다.
    private func select(mogakID: Int) {
        guard state.selectedMogakID != mogakID else { return }
        state.selectedMogakID = mogakID
        state.jogaks = []
    }

    private func reloadJogaks(mogakID: Int) async throws {
        let jogaks = try await useCase.getMogakJogaks(mogakId: mogakID)
        // 그사이 다른 모각을 골랐으면 늦게 온 결과는 버린다.
        guard state.selectedMogakID == mogakID else { return }
        state.jogaks = jogaks
    }

    private func makeActionContext(detail: MG2JogakDetailEntity) -> MG2JogakActionContext {
        let days = localizedDays(from: detail.days)
        let summary = MG2JogakSummaryViewData(category: detail.category.name, categoryColor: detail.color ?? DesignSystemPalette.signatureHex, title: detail.title, isRoutine: detail.isRoutine, routineDaysText: days.isEmpty ? "미지정" : days.joined(separator: ","), periodText: periodText(for: detail))
        return MG2JogakActionContext(detail: detail, summary: summary)
    }

    private func localizedDays(from days: [MG2Weekday]) -> [String] {
        days.sorted { $0.rawValue < $1.rawValue }.map(\.shortKoreanTitle)
    }

    /// 단발 조각은 그날 하루, 루틴은 시작일 ~ 종료일. 종료일을 안 정한 루틴은 "시작일 ~ 미지정".
    private func periodText(for detail: MG2JogakDetailEntity) -> String {
        guard let startDate = detail.startDate else { return "미지정" }
        let startText = Self.displayDateFormatter.string(from: startDate)
        guard detail.isRoutine else { return startText }
        guard let endDate = detail.endDate else { return "\(startText) ~ 미지정" }
        return "\(startText) ~ \(Self.displayDateFormatter.string(from: endDate))"
    }
}
