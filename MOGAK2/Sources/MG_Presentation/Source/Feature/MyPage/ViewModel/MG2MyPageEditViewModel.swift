import Foundation
import Combine

@MainActor
final class MG2MyPageEditViewModel {
    let profileImageIDs = MG2ProfileImage.ids

    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCase
    private let userState: MG2UserState

    init(authUseCase: AuthUseCase, userUseCase: UserUseCase, userState: MG2UserState) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
        self.userState = userState
    }

    var profilePublisher: AnyPublisher<MG2MyPageProfileState, Never> { MG2MyPageProfileState.publisher(for: userState) }

    var selectedProfileImageIndex: Int? { userState.profileImageID.flatMap(profileImageIDs.firstIndex(of:)) }

    /// 고른 이미지는 바로 저장한다. 저장된 값은 MG2UserState를 통해 화면에 반영된다.
    func selectProfileImage(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard profileImageIDs.indices.contains(index) else { return }
        let imageID = profileImageIDs[index]
        Task {
            do {
                try await userUseCase.changeProfileImage(imageID)
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
