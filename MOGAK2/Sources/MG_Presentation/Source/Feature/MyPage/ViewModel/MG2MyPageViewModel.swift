import Foundation
import Combine

struct MG2MyPageProfileState {
    let name: String
    let job: String
}

@MainActor
final class MG2MyPageViewModel {
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    private let userState: MG2UserState
    private let sessionStore: MG2SessionStoring

    init(
        userUseCase: UserUseCase,
        authUseCase: AuthUseCase,
        userState: MG2UserState,
        sessionStore: MG2SessionStoring
    ) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.userState = userState
        self.sessionStore = sessionStore
    }

    var isGuest: Bool { userState.loginState == .guest }
    var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "" }

    var profilePublisher: AnyPublisher<MG2MyPageProfileState, Never> {
        userState.$nickname
            .combineLatest(
                userState.$job,
                userState.$loginState
            )
            .map { nickname, job, loginState in
                guard loginState != .guest else {
                    return MG2MyPageProfileState(
                        name: "로그인이 필요합니다.",
                        job: "환영합니다!"
                    )
                }
                return MG2MyPageProfileState(
                    name: nickname,
                    job: job
                )
            }
            .eraseToAnyPublisher()
    }

    func fetchUserData(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let profile = try await userUseCase.getUserProfile()
                userState.nickname = profile.nickname
                userState.job = profile.job
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await authUseCase.logout()
                sessionStore.clearAuthentication()
                userState.loginState = .logout
                userState.isRegistered = false
                userState.resetProfile()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func withdraw(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let deleted = try await authUseCase.withdraw()
                if deleted {
                    sessionStore.resetAfterWithdrawal()
                    userState.loginState = .logout
                    userState.isRegistered = false
                    userState.resetProfile()
                }
                completion(.success(deleted))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
