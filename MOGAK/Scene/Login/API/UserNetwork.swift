//
//  UserNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import Alamofire
import Kingfisher
import UIKit

#if false
// Legacy MOGAK1 login API implementation (inactive after migration to MOGAK2 Data/Domain/Presentation).

class UserNetwork {
    static let shared = UserNetwork()
    //MARK: - 닉네임 검증
    func nicknameVerify(_ nickname: String, completionHandler: @escaping(Result<String, AFError>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyUserBridge.shared.nicknameVerify(nickname) { result in
            switch result {
            case .success(let response):
                if response.code == "success" {
                    completionHandler(.success("성공"))
                } else {
                    completionHandler(.success(response.message))
                }
            case .failure(let error):
                completionHandler(.failure(AFError.sessionTaskFailed(error: error)))
            }
        }

        // Legacy MOGAK1 route (inactive)
        // let nicknameRequest = NicknameChangeRequest(nickname: nickname)
        // AF.request(UserRouter.nicknameVerify(nickname: nicknameRequest))
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: NicknameVerify.self) { (response: DataResponse<NicknameVerify, AFError>) in
        //         switch response.result {
        //         case .success(let nicknameVerify):
        //             if nicknameVerify.code == "success" {
        //                 completionHandler(.success("성공"))
        //             }
        //         case .failure(let error):
        //             if response.response?.statusCode == 409 {
        //                 completionHandler(.failure(error.asAFError(orFailWith: "올바르지 않은 닉네임")))
        //             }
        //         }
        //     }
    }
    
    //MARK: - 유저 계정 생성
    func userJoin(_ userData: UserInfoData, _ profileImg: UIImage?, completionHandler: @escaping(Result<Bool, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyUserBridge.shared.userJoin(userData, profileImg, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.upload(multipartFormData: ..., to: url, method: .post, headers: header)
        //    .validate(statusCode: 200..<300)
        //    .responseDecodable(of: UserInfoDataResponse.self) { ... }
       }
    
    //MARK: - 유저 닉네임 변경
    func nicknameChange(_ nickname: String, completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        MG2LegacyUserBridge.shared.nicknameChange(nickname) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }

        // Legacy MOGAK1 route (inactive)
        // let nicknameRequest = NicknameChangeRequest(nickname: nickname)
        // AF.request(UserRouter.nicknameChange(nickname: nicknameRequest), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ChangeSuccessResponse.self) { ... }
    }
    
    //MARK: - 유저 직무 변경
    func jobChange(_ job: JobChangeRequest, completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        MG2LegacyUserBridge.shared.jobChange(job.job) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }

        // Legacy MOGAK1 route (inactive)
        // AF.request(UserRouter.jobChange(job: job), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: UserInfoChangeResponse.self) { ... }
    }
    
    //MARK: - 유저 프로필사진 변경
    func userImageChange(_ profileImg: UIImage, completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        MG2LegacyUserBridge.shared.userImageChange(profileImg, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.upload(multipartFormData: ..., to: url, method: .put, headers: header, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ChangeSuccessResponse.self) { ... }
    }
    
    func getUserData(_ completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        LoadingIndicator.showLoading()
        // MOGAK2 bridge route (active)
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

        // Legacy MOGAK1 route (inactive)
        // AF.request(UserRouter.getUserData, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseData { ... }
    }
    
    //MARK: - 유저 로그아웃
    func userLogout(_ completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        MG2LegacyAuthBridge.shared.userLogout(completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(LoginRouter.logout, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: LogoutResponse.self) { (response: DataResponse<LogoutResponse, AFError>) in
        //         switch response.result {
        //         case .success(let logoutReponse):
        //             if logoutReponse.code == "success" {
        //                 UserDefaults.standard.set("", forKey: "refreshToken")
        //                 UserDefaults.standard.synchronize()
        //                 completionHandler(.success(true))
        //             }
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 회원탈퇴
    func withDraw(_ completionHandler: @escaping((Result<Bool, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        MG2LegacyAuthBridge.shared.withDraw(completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(LoginRouter.withDraw, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseData { response in
        //         let statusCode = response.response?.statusCode
        //         switch response.result {
        //         case .success(let data):
        //             let decoder = JSONDecoder()
        //             if (200..<300).contains(statusCode ?? 0) {
        //                 let decodeData = try? decoder.decode(WithDrawResponse.self, from: data)
        //                 guard let isUserDeleted = decodeData?.result.deleted else { return }
        //                 if isUserDeleted {
        //                     RegisterUserInfo.shared.profileImage = nil
        //                     UserDefaults.standard.set("", forKey: "refreshToken")
        //                     UserDefaults.standard.set(true, forKey: "isFirstTime")
        //                     UserDefaults.standard.synchronize()
        //                     completionHandler(.success(true))
        //                 }
        //             } else {
        //                 completionHandler(.success(false))
        //             }
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
}

#endif
