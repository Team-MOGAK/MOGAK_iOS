import Foundation

final class MG2MyHistoryViewModel {
    private let modalartViewModel: MG2ModalartViewModel

    init(modalartViewModel: MG2ModalartViewModel = MG2ModalartViewModel()) {
        self.modalartViewModel = modalartViewModel
    }

    func getModalartList(completion: @escaping (Result<[ModalartList]?, Error>) -> Void) {
        modalartViewModel.getModalartList(completion: completion)
    }

    func getDetailModalartInfo(modalartId: Int, completion: @escaping (Result<ModalartInfo?, Error>) -> Void) {
        modalartViewModel.getDetailModalartInfo(modalartId: modalartId, completion: completion)
    }
}
