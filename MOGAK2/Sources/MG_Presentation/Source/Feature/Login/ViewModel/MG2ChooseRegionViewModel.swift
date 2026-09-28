import Foundation

@MainActor
final class MG2ChooseRegionViewModel {
    private let userUseCase: UserUseCase
    private let draft: MG2RegistrationDraft
    private(set) var regions = [String]()
    private(set) var selectedRegion = ""

    init(userUseCase: UserUseCase, draft: MG2RegistrationDraft) {
        self.userUseCase = userUseCase
        self.draft = draft
    }

    func loadRegions(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                regions = try await userUseCase.getAddresses()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func selectRegion(at index: Int) {
        guard regions.indices.contains(index) else { return }
        selectedRegion = regions[index]
    }

    func join(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !selectedRegion.isEmpty else { return }
        let registration = MG2UserRegistration(nickname: draft.nickname, job: draft.job, address: selectedRegion, consents: draft.consents, profileImageID: draft.profileImageID)
        Task {
            do {
                try await userUseCase.join(registration)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
