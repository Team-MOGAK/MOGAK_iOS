//
//  CommonLoginManage.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/11.
//

import UIKit
import Alamofire

class CommonLoginManage: RequestInterceptor {
    //MARK: - Authorization header에 넣어줌
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else { return }
        print(#fileID, #function, #line, "- adapt accessToken: \(accessToken)")
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(urlRequest))
    }
    
    //MARK: - accessToken이 만료되었을때 refreshToken 통해 accessToken재발급
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let requestToken = UserDefaults.standard.string(forKey: "refreshToken") else { return }
        print(#fileID, #function, #line, "- refreshToken check: \(requestToken)")
        
        guard let response = request.task?.response as? HTTPURLResponse else { return }
        
        // adapt를해서 돌아올때 statusCode가 401일 경우 -> accessToken만료된 것(재발급)
        if response.statusCode == 401 {
            AF.request(LoginRouter.getNewAccessToken(refreshToken: requestToken))
                .validate(statusCode: 200..<300)
                .responseDecodable(of: RefreshTokenResponse.self) { (response: DataResponse<RefreshTokenResponse, AFError> ) in
                    switch response.result {
                    case .failure(let error):
                        completion(.doNotRetry)
                    case .success(let data):
                        UserDefaults.standard.set(data.result?.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(data.result?.refreshToken, forKey: "refreshToken")
                        completion(.retry)
                    }
                    
                }
        }
        //ex. 닉네임 변경시 -> 이미 존재하고 있는 닉네임(404), 옳지 않은 닉네임(409)
        //404, 409는 nicknameVerify & nicknameChange시 잘못된 파라미터
        else if response.statusCode == 404 || response.statusCode == 409 {
            completion(.doNotRetry)
#warning("404, 409 외에 로그아웃 처리하지 않고 alert창 같은 거 띄워줘야 할 경우 여기에 남겨주면 추가")
        }
        //401, 404, 409 이외에는 로그아웃 -> 로그인VC로 이동
        else {
            print(#fileID, #function, #line, "- responseStaus: \(response.statusCode)")
            RegisterUserInfo.shared.someError = String(response.statusCode) + "\n" + error.localizedDescription
            RegisterUserInfo.shared.happendSomeError = true
            completion(.doNotRetryWithError(error))
            UserDefaults.standard.set("", forKey: "refreshToken")
            RegisterUserInfo.shared.loginState = .logout
        }
            
    }
    
    static func gotoLoginViewController(_ vc: UIViewController) {
        let gotoLoginAlertAction = UIAlertAction(title: "네", style: .default) { _ in
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .overFullScreen
            vc.present(loginVC, animated: false)
        }
        
        let cancelAlertAction = UIAlertAction(title: "아니요", style: .cancel)
        
        let needLoginAlertController = UIAlertController(title: "로그인 필요", message: "해당 기능을 사용하시려면 로그인이 필요합니다. \n로그인 화면으로 이동하시겠습니까?", preferredStyle: .alert)
        
        needLoginAlertController.addAction(gotoLoginAlertAction)
        needLoginAlertController.addAction(cancelAlertAction)
        vc.present(needLoginAlertController, animated: false)
    }
}
