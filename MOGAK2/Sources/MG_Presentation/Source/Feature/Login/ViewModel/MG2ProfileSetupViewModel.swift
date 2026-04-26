import Foundation
import UIKit

final class MG2ProfileSetupViewModel {
    private let userUseCase: UserUseCase

    init(userUseCase: UserUseCase? = DIContainer.shared.resolve(UserUseCase.self)) {
        guard let userUseCase else {
            fatalError("UserUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        self.userUseCase = userUseCase
    }

    func validateNickname(_ nickname: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let response = try await userUseCase.verifyNickname(nickname)
                completion(.success(response.message))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func changeNickname(_ nickname: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                _ = try await userUseCase.changeNickname(nickname)
                MG2Deps.app.userState.nickName = nickname
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func changeProfileImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            completion(.failure(NSError(domain: "MG2ProfileSetupViewModel", code: -1)))
            return
        }
        let nickname = MG2Deps.app.userState.nickName ?? ""
        Task {
            do {
                let result = try await userUseCase.userImageChange(imageData: data, userNickname: nickname)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func changeJob(_ job: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                _ = try await userUseCase.changeJob(job)
                MG2Deps.app.userState.userJob = job
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func joinUser(nickname: String,
                  job: String,
                  region: String,
                  email: String,
                  profileImage: UIImage?,
                  completion: @escaping (Result<Bool, Error>) -> Void) {
        let data = UserInfoData(
            nickname: nickname,
            job: job,
            address: region,
            email: email,
            multipartFile: ""
        )
        let imageData = profileImage?.jpegData(compressionQuality: 1.0)
        Task {
            do {
                let joined = try await userUseCase.userJoin(userData: data, profileImageData: imageData)
                completion(.success(joined))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
