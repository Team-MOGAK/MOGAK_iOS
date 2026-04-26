import Foundation

extension MG2LegacyAuthBridge {

    func revokeAppleToken(refreshToken: String, completion: ((Error?) -> Void)? = nil) {
        Task {
            do {
                try await useCase.revokeAppleToken(refreshToken: refreshToken)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
