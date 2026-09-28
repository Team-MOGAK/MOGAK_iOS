import Foundation

struct MG2ModalartOption {
    let id: Int
    let title: String
    let color: String
}

@MainActor
final class MG2SelectModalartViewModel {
    let scheduledDate: Date
    private let useCase: ScheduleStartUseCase
    private(set) var modalarts = [MG2ModalartOption]()

    init(useCase: ScheduleStartUseCase, scheduledDate: Date) {
        self.useCase = useCase
        self.scheduledDate = scheduledDate
    }

    func loadModalarts(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                modalarts = try await useCase.getModalartList().map { MG2ModalartOption(id: $0.id, title: $0.title, color: $0.color) }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
