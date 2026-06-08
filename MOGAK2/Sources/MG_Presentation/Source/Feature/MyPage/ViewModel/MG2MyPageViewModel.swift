import Foundation

@MainActor
final class MG2MyPageViewModel {
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase

    init(
        userUseCase: UserUseCase,
        authUseCase: AuthUseCase
    ) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
    }

    var isGuest: Bool { MG2Deps.app.userState.loginState == .guest }

    func fetchUserData(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let profile = try await userUseCase.getUserProfile()
                MG2Deps.app.userState.nickName = profile.nickname
                MG2Deps.app.userState.userJob = profile.job
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                try await authUseCase.logout(accessToken: MG2TokenStore.accessToken)
                MG2TokenStore.clearTokens()
                MG2Deps.app.userState.loginState = .logout
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func withdraw(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let deleted = try await authUseCase.withdraw(accessToken: MG2TokenStore.accessToken)
                if deleted {
                    MG2TokenStore.clearTokens()
                    MG2Deps.app.userState.loginState = .logout
                }
                completion(.success(deleted))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
