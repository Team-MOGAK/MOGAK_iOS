import Foundation

final class MG2MyPageViewModel {
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase

    init(
        userUseCase: UserUseCase? = DIContainer.shared.resolve(UserUseCase.self),
        authUseCase: AuthUseCase? = DIContainer.shared.resolve(AuthUseCase.self)
    ) {
        guard let userUseCase, let authUseCase else {
            fatalError("UserUseCase/AuthUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
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
                try await authUseCase.logout(accessToken: UserDefaults.standard.string(forKey: "accessToken"))
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
                let deleted = try await authUseCase.withdraw(accessToken: UserDefaults.standard.string(forKey: "accessToken"))
                if deleted {
                    MG2Deps.app.userState.loginState = .logout
                }
                completion(.success(deleted))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
