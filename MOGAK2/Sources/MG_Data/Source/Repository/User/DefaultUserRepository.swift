import Foundation

final class DefaultUserRepository: UserRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getJobs() async throws -> [String] {
        let response: MG2MetadataListResponseDTO = try await networkProvider.request(
            target: MG2UserRouter.jobs
        )
        return response.result.map(\.name)
    }

    func getAddresses() async throws -> [String] {
        let response: MG2MetadataListResponseDTO = try await networkProvider.request(
            target: MG2UserRouter.addresses
        )
        return response.result.map(\.name)
    }

    func getConsentItems() async throws -> [MG2ConsentItemEntity] {
        let response: MG2ConsentListResponseDTO = try await networkProvider.request(
            target: MG2UserRouter.consents
        )
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
        let response: MG2GetUserProfileResponseDTO = try await networkProvider.request(target: MG2UserRouter.getUserProfile)
        return response.result.toEntity()
    }

    func userJoin(registration: MG2UserRegistration) async throws -> MG2UserRegistrationResult {
        let response: MG2UserRegistrationResponseDTO = try await networkProvider.request(
            target: MG2UserRouter.join(
                nickname: registration.nickname,
                job: registration.job,
                address: registration.address,
                consents: registration.consents
            )
        )
        return response.result.toEntity()
    }
}
