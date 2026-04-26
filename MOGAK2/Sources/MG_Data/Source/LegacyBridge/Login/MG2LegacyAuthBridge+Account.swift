import Foundation

extension MG2LegacyAuthBridge {

    func userLogout(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                try await useCase.logout(accessToken: UserDefaults.standard.string(forKey: "accessToken"))
                UserDefaults.standard.set("", forKey: "refreshToken")
                UserDefaults.standard.synchronize()
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func withDraw(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let deleted = try await useCase.withdraw(accessToken: UserDefaults.standard.string(forKey: "accessToken"))
                if deleted {
                    RegisterUserInfo.shared.profileImage = nil
                    UserDefaults.standard.set("", forKey: "refreshToken")
                    UserDefaults.standard.set(true, forKey: "isFirstTime")
                    UserDefaults.standard.synchronize()
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
