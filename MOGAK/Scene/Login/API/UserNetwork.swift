//
//  UserNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import Alamofire

class UserNetwork {
    func nicknameVerify(_ nickname: String, completionHandler: @escaping(Result<String, Error>) -> Void) {
        AF.request(UserRouter.nicknameVerify(nickname: nickname))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: NicknameVerify.self) { (response: DataResponse<NicknameVerify, AFError>) in
                switch response.result {
                case .success(let nicknameVerify):
                    if nicknameVerify.code == "success" {
                        return completionHandler(.success(""))
                    } else {
                        return completionHandler(.success(nicknameVerify.message))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    
                                                 
    func userJoin(_ userData: UserInfoData, _ profileImg: UIImage, completionHandler: @escaping(Result<Bool, Error>) -> Void) {
        var url = "https://mogak.shop:8080/api/users/join"
        let header: HTTPHeaders = [
                    "Accept" : "application/json, application/javascript, text/javascript, text/json",
                    "Content-Type" : "multipart/form-data"
                ]
        AF.upload(multipartFormData: { MultipartFormData in
            
            // body 추가
            let parameters: [String : Any] = ["nickname" : userData.nickname,
                                              "job" : userData.job,
                                              "address" : userData.address,
                                              "email" : userData.email]
            
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            
            if let image = profileImg.jpegData(compressionQuality: 1) {
                MultipartFormData.append(image, withName: "file", fileName: "\(userData.nickname).jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: header)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: UserInfoData.self, completionHandler:  { response in
            switch response.result{
            case .success(let data):
                print("url : \(data.nickname)")
                completionHandler(.success(true))
            case .failure(let error):
              print(error)
            }
        })
    }
    
    
}
