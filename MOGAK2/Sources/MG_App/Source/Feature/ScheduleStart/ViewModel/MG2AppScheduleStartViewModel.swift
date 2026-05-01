import Foundation
import Combine

enum MG2AppScheduleStartViewState {
    case idle
    case loading
    case loaded([ScheduleModalart])
    case failed(String)
}

protocol MG2AppScheduleStartRouting: AnyObject {
    func showModalartDetail(modalartId: Int)
}

final class MG2AppScheduleStartViewModel {

    @Published private(set) var state: MG2AppScheduleStartViewState = .idle

    private let useCase: ScheduleStartUseCase
    weak var coordinator: MG2AppScheduleStartRouting?

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
