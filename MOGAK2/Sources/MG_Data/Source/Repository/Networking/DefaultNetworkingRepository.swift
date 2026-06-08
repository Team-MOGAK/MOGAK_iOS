import Foundation

final class DefaultNetworkingRepository: NetworkingRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getPacemakerFeeds(cursor: Int, size: Int) async throws -> [MG2NetworkingFeedEntity] {
        let response: PacemakerFeedsResponse = try await networkProvider.request(
            target: MG2NetworkingRouter.pacemakerFeeds(cursor: cursor, size: size)
        )
        return response.result.compactMap { $0.toEntity() }
    }
}
