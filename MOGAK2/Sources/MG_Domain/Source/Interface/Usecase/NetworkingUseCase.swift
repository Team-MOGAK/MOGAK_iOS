import Foundation

protocol NetworkingUseCase {
    func getPacemakerFeeds(cursor: Int, size: Int) async throws -> [MG2NetworkingFeedEntity]
}
