import Foundation
import AuthenticationServices
import CryptoKit
import Security

final class MG2AppleLoginManage: NSObject {
    let registerUserInfo = RegisterUserInfo.shared
    static let shared = MG2AppleLoginManage()

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    fileprivate var currentNonce: String?

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension MG2AppleLoginManage: ASAuthorizationControllerDelegate {
    private func base64URLDecode(_ value: String) -> Data? {
        var base64 = value.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let pad = 4 - (base64.count % 4)
        if pad < 4 { base64 += String(repeating: "=", count: pad) }
        return Data(base64Encoded: base64)
    }

    private func logAppleTokenClaims(_ token: String) {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else {
            print("[AppleLogin] invalid jwt format")
            return
        }
        guard
            let payloadData = base64URLDecode(String(parts[1])),
            let payloadText = String(data: payloadData, encoding: .utf8)
        else {
            print("[AppleLogin] payload decode failed")
            return
        }
        print("[AppleLogin][JWT Payload] \(payloadText)")
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }

            logAppleTokenClaims(idTokenString)

            MG2LegacyAuthBridge.shared.login(idToken: idTokenString) { result in
                switch result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                case .success(let session):
                    UserDefaults.standard.set(session.tokens.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(session.tokens.refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.set(session.userId, forKey: "userId")
                    UserDefaults.standard.synchronize()

                    self.registerUserInfo.userIsRegistered = session.isRegistered
                    let userEmail = appleIDCredential.email ?? "이메일 제공안함"
                    self.registerUserInfo.userEmail = userEmail
                    self.registerUserInfo.loginState = .login
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }

    func appleLoginDeleteUser() {
        let token = UserDefaults.standard.string(forKey: "refreshToken")
        if let token = token {
            MG2LegacyAuthBridge.shared.revokeAppleToken(refreshToken: token) { error in
                print(#fileID, #function, #line, "- revoke token error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
