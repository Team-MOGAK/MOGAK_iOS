import Foundation
import Combine

@MainActor
final class MG2MyPageViewModel {
    private let userUseCase: UserUseCase
    private let userState: MG2UserState
    private let adPolicyUseCase: AdPolicyUseCase

    init(userUseCase: UserUseCase, userState: MG2UserState, adPolicyUseCase: AdPolicyUseCase) {
        self.userUseCase = userUseCase
        self.userState = userState
        self.adPolicyUseCase = adPolicyUseCase
    }

    var isGuest: Bool { userState.loginState == .guest }
    var canShowBanner: Bool { adPolicyUseCase.canShowBanner }
    var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "" }
    var profilePublisher: AnyPublisher<MG2MyPageProfileState, Never> { MG2MyPageProfileState.publisher(for: userState) }

    func fetchUserData(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await userUseCase.loadProfile()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
