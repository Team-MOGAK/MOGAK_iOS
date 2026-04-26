import Foundation

final class MG2LegacyMogakDetailBridge {

    static let shared = MG2LegacyMogakDetailBridge()

    private let useCase: ModalartUseCase

    private init() {
        let provider = DefaultNetworkProvider(session: .default)
        let repository = DefaultModalartRepository(networkProvider: provider)
        self.useCase = DefaultModalartUseCase(repository: repository)
    }

    func getAllMogakDetailJogaks(mogakId: Int, date: String, completion: @escaping (Result<[JogakDetail]?, Error>) -> Void) {
        Task {
            do {
                let items = try await useCase.getMogakDetailJogaks(mogakId: mogakId, date: date)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteMogak(mogakId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let deleted = try await useCase.deleteMogak(mogakId: mogakId)
                completion(.success(deleted))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteJogak(jogakId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let deleted = try await useCase.deleteJogak(jogakId: jogakId)
                completion(.success(deleted))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
