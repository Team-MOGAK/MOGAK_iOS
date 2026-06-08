import Foundation

protocol NetworkingRepository {
    func getPacemakerFeeds(cursor: Int, size: Int) async throws -> [MG2NetworkingFeedEntity]
}
