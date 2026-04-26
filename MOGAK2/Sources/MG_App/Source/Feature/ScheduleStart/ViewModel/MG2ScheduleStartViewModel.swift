import Foundation
import Combine

enum MG2ScheduleStartViewState {
    case idle
    case loading
    case loaded([ScheduleModalart])
    case failed(String)
}

protocol MG2ScheduleStartRouting: AnyObject {
    func showModalartDetail(modalartId: Int)
}

final class MG2ScheduleStartViewModel {

    @Published private(set) var state: MG2ScheduleStartViewState = .idle

    private let useCase: ScheduleStartUseCase
    weak var coordinator: MG2ScheduleStartRouting?

    init(useCase: ScheduleStartUseCase) {
        self.useCase = useCase
    }

    func onAppear() {
        Task { await loadModalarts() }
    }

    func didTapModalart(id: Int) {
        coordinator?.showModalartDetail(modalartId: id)
    }

    @MainActor
    private func loadModalarts() async {
        state = .loading

        do {
            let modalarts = try await useCase.getModalartList()
            state = .loaded(modalarts)
        } catch {
            state = .failed("모다라트 목록을 불러오지 못했습니다.")
        }
    }
}
