import Foundation
import Combine

@MainActor
final class MG2MyPageEditViewModel {
    private let authUseCase: AuthUseCase
    private let userState: MG2UserState

    init(authUseCase: AuthUseCase, userState: MG2UserState) {
        self.authUseCase = authUseCase
        self.userState = userState
    }

    var profilePublisher: AnyPublisher<MG2MyPageProfileState, Never> { MG2MyPageProfileState.publisher(for: userState) }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await authUseCase.logout()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func withdraw(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await authUseCase.withdraw()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
