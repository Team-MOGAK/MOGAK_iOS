import Foundation
import AuthenticationServices
import CryptoKit
import Security

final class MG2AppleLoginManage: NSObject {
    let registerUserInfo = RegisterUserInfo.shared
    static let shared = MG2AppleLoginManage()
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase? = DIContainer.shared.resolve(AuthUseCase.self)) {
        guard let authUseCase else {
            fatalError("AuthUseCase is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        self.authUseCase = authUseCase
        super.init()
    }

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
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.startSignInWithAppleFlow() }
            return
        }
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

            Task { @MainActor in
                do {
                    let session = try await authUseCase.login(idToken: idTokenString)
                    MG2TokenStore.save(accessToken: session.tokens.accessToken, refreshToken: session.tokens.refreshToken)
                    UserDefaults.standard.set(session.userId, forKey: "userId")

                    self.registerUserInfo.userIsRegistered = session.isRegistered
                    let userEmail = appleIDCredential.email ?? "이메일 제공안함"
                    self.registerUserInfo.userEmail = userEmail
                    self.registerUserInfo.loginState = .login
                } catch {
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }

    func appleLoginDeleteUser() {
        let token = MG2TokenStore.refreshToken
        if let token = token {
            Task {
                do {
                    try await authUseCase.revokeAppleToken(refreshToken: token)
                } catch {
                    print(#fileID, #function, #line, "- revoke token error: \(error.localizedDescription)")
                }
            }
        }
    }
}
