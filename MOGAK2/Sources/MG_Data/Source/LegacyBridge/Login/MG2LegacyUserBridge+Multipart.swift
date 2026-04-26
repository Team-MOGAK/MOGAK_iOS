import Foundation
import UIKit

extension MG2LegacyUserBridge {

    func userJoin(_ userData: UserInfoData, _ profileImg: UIImage?, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let imageData = profileImg?.jpegData(compressionQuality: 1)
                let result = try await useCase.userJoin(userData: userData, profileImageData: imageData)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func userImageChange(_ profileImg: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                guard let imageData = profileImg.jpegData(compressionQuality: 1) else {
                    completion(.success(false))
                    return
                }
                let userNickname = RegisterUserInfo.shared.userName ?? "profile"
                let result = try await useCase.userImageChange(imageData: imageData, userNickname: userNickname)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
