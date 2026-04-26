import Foundation

extension MG2LegacyAuthBridge {

    func login(idToken: String, completion: @escaping (Result<MG2AuthSession, Error>) -> Void) {
        Task {
            do {
                let session = try await useCase.login(idToken: idToken)
                completion(.success(session))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func refreshToken(_ refreshToken: String, completion: @escaping (Result<MG2TokenPair, Error>) -> Void) {
        Task {
            do {
                let token = try await useCase.refresh(refreshToken: refreshToken)
                completion(.success(token))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
