import Foundation

final class DefaultNetworkingUseCase: NetworkingUseCase {
    private let repository: NetworkingRepository

    init(repository: NetworkingRepository) {
        self.repository = repository
    }

    func getPacemakerFeeds(cursor: Int, size: Int) async throws -> [MG2NetworkingFeedEntity] {
        try await repository.getPacemakerFeeds(cursor: cursor, size: size)
    }
}
