//
//  AppleLoginManage.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/08.
//

import Foundation
import AuthenticationServices
import CryptoKit
import Security
import Combine
import Alamofire

struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

struct LoginRequest: Codable {
    let idToken: String
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

// MARK: - Welcome
struct LoginResponse: Codable {
    let isRegistered: Bool
    let userID: Int
    let tokens: Tokens

    enum CodingKeys: String, CodingKey {
        case isRegistered
        case userID = "userId"
        case tokens
    }
}

// MARK: - Tokens
struct Tokens: Codable {
    let accessToken, refreshToken: String
}


final class AppleLoginManage: NSObject {
    let registerUserInfo = RegisterUserInfo.shared
    static let shared = AppleLoginManage()
    
    //MARK: - ID토큰이 명시적으로 부여되었는지 확인
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        //nonce생성
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    //MARK: - nonce를 hash하는 코드
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    //MARK: - 애플 로그인 시작
    @available(iOS 13, *)
        func startSignInWithAppleFlow() {
            print(#fileID, #function, #line, "- 애플 로그인 시작🍎")
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest() //request만들기
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
    
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
}


extension AppleLoginManage: ASAuthorizationControllerDelegate {
    //MARK: - 애플 로그인 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(#fileID, #function, #line, "- 애플 로그인 성공🍎")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
    
            if let authorizationCode = appleIDCredential.authorizationCode,
               let codeString = String(data: authorizationCode, encoding: .utf8) {
                print(#fileID, #function, #line, "- codeString🔥: \(codeString)")
                let loginRequestTokenData = LoginRequest(idToken: idTokenString)
                
                AF.request(LoginRouter.login(data: loginRequestTokenData))
                    .responseDecodable(of: LoginResponse.self) { (response: DataResponse<LoginResponse, AFError> ) in
                        switch response.result {
                        case .failure(let error):
                            print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                        case .success(let data):
                            print(#fileID, #function, #line, "- sucess")
                            print(#fileID, #function, #line, "- data.tokens: \(data.tokens)")
                            UserDefaults.standard.set(data.tokens.accessToken, forKey: "accessToken")
                            UserDefaults.standard.set(data.tokens.refreshToken, forKey: "refreshToken")
                            UserDefaults.standard.synchronize()
                            let userEmail = appleIDCredential.email ?? "이메일 제공안함"
                            self.registerUserInfo.userEmail = userEmail
                            self.registerUserInfo.loginState = true
                        }
                    }

            }
        }
    }//authorizationController 성공
    
    //MARK: - 애플 로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    //MARK: - 애플 로그인 회원 탈퇴
    func appleLoginDeleteUser() {
        let token = UserDefaults.standard.string(forKey: "refreshToken")
        print(#fileID, #function, #line, "- token checking⭐️: \(String(describing: token))")
        //token으로 데이터 삭제
        if let token = token {
            let url = URL(string: "https://us-central1-pickdrink-492de.cloudfunctions.net/revokeToken?refresh_token=\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com")!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard data != nil else { return }
                print(#fileID, #function, #line, "- revoke token error🔥: \(String(describing: error?.localizedDescription))")
                print(#fileID, #function, #line, "- revokeToken response checking🔥: \(String(describing: response))")
                
            }
            task.resume()
        }
        print(#fileID, #function, #line, "- revokeToken success⭐️")
        // Delete other information from the database...
        
    }
}
