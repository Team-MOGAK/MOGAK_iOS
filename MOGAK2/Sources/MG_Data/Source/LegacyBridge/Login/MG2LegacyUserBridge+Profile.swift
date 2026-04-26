import Foundation

extension MG2LegacyUserBridge {

    func nicknameVerify(_ nickname: String, completion: @escaping (Result<NicknameVerify, Error>) -> Void) {
        Task {
            do {
                let response = try await useCase.verifyNickname(nickname)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func nicknameChange(_ nickname: String, completion: @escaping (Result<ChangeSuccessResponse, Error>) -> Void) {
        Task {
            do {
                let response = try await useCase.changeNickname(nickname)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func jobChange(_ job: String, completion: @escaping (Result<UserInfoChangeResponse, Error>) -> Void) {
        Task {
            do {
                let response = try await useCase.changeJob(job)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getUserData(completion: @escaping (Result<GetUserDataSuccessResponse, Error>) -> Void) {
        Task {
            do {
                let profile = try await useCase.getUserProfile()
                completion(.success(GetUserDataSuccessResponse(
                    time: "",
                    status: "",
                    code: "success",
                    message: "",
                    result: UserRealData(nickname: profile.nickname, job: profile.job, imgURL: profile.imageURL)
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
