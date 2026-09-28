import Foundation

final class DefaultUserRepository: UserRepository {
    private let networkProvider: NetworkProvider
    // 프로필 이미지는 서버에 보내지 않고 기기에 저장한다. 서버로 옮기면 이 두 곳만 바꾸면 된다.
    private let loadProfileImageID: () -> Int?
    private let saveProfileImageID: (Int) -> Void

    init(networkProvider: NetworkProvider, loadProfileImageID: @escaping () -> Int?, saveProfileImageID: @escaping (Int) -> Void) {
        self.networkProvider = networkProvider
        self.loadProfileImageID = loadProfileImageID
        self.saveProfileImageID = saveProfileImageID
    }

    func getJobs() async throws -> [String] {
        let response: MG2ResponseDTO<[MG2MetadataItemDTO]> = try await networkProvider.request(target: MG2UserRouter.jobs)
        return response.result.map(\.name)
    }

    func getAddresses() async throws -> [String] {
        let response: MG2ResponseDTO<[MG2MetadataItemDTO]> = try await networkProvider.request(target: MG2UserRouter.addresses)
        return response.result.map(\.name)
    }

    func getConsentItems() async throws -> [MG2ConsentItemEntity] {
        let response: MG2ResponseDTO<[MG2ConsentItemDTO]> = try await networkProvider.request(target: MG2UserRouter.consents)
        return response.result.map { $0.toEntity() }
    }

    func verifyNickname(_ nickname: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.nicknameVerify(nickname: nickname))
    }

    func changeNickname(_ nickname: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.nicknameChange(nickname: nickname))
    }

    func changeJob(_ job: String) async throws {
        try await networkProvider.requestEmpty(target: MG2UserRouter.jobChange(job: job))
    }

    func getUserProfile() async throws -> MG2UserProfileEntity {
        let response: MG2ResponseDTO<MG2UserProfileDTO> = try await networkProvider.request(target: MG2UserRouter.getUserProfile)
        return response.result.toEntity(profileImageID: loadProfileImageID())
    }

    func changeProfileImage(_ imageID: Int) async throws {
        saveProfileImageID(imageID)
    }

    func userJoin(registration: MG2UserRegistration) async throws -> MG2UserRegistrationResult {
        let response: MG2ResponseDTO<MG2UserRegistrationResultDTO> = try await networkProvider.request(target: MG2UserRouter.join(nickname: registration.nickname, job: registration.job, address: registration.address, consents: registration.consents))
        return response.result.toEntity()
    }
}
