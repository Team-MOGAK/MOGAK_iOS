import Foundation
import Kingfisher
import UIKit

final class MG2UserNetwork {
    static let shared = MG2UserNetwork()

    private init() {}

    func nicknameVerify(_ nickname: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        MG2LegacyUserBridge.shared.nicknameVerify(nickname) { result in
            switch result {
            case .success(let response):
                if response.code == "success" {
                    completionHandler(.success("성공"))
                } else {
                    completionHandler(.success(response.message))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func userJoin(_ userData: UserInfoData, _ profileImg: UIImage?, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyUserBridge.shared.userJoin(userData, profileImg, completion: completionHandler)
    }

    func nicknameChange(_ nickname: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyUserBridge.shared.nicknameChange(nickname) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func jobChange(_ job: JobChangeRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyUserBridge.shared.jobChange(job.job) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func userImageChange(_ profileImg: UIImage, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyUserBridge.shared.userImageChange(profileImg, completion: completionHandler)
    }

    func getUserData(_ completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        LoadingIndicator.showLoading()
        MG2LegacyUserBridge.shared.getUserData { result in
            switch result {
            case .success(let response):
                let profile = response.result
                RegisterUserInfo.shared.nickName = profile.nickname
                RegisterUserInfo.shared.userJob = profile.job
                if let thumbnailUrl = URL(string: profile.imgURL ?? "") {
                    KingfisherManager.shared.retrieveImage(with: thumbnailUrl) { imageResult in
                        switch imageResult {
                        case .success(let image):
                            RegisterUserInfo.shared.profileImage = image.image
                        case .failure:
                            break
                        }
                    }
                }
                LoadingIndicator.hideLoading()
                completionHandler(.success(true))
            case .failure(let error):
                LoadingIndicator.hideLoading()
                completionHandler(.failure(error))
            }
        }
    }

    func userLogout(_ completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyAuthBridge.shared.userLogout(completion: completionHandler)
    }

    func withDraw(_ completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        MG2LegacyAuthBridge.shared.withDraw(completion: completionHandler)
    }
}
