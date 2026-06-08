import Foundation

@MainActor
final class MG2NetworkingViewModel {
    private let useCase: NetworkingUseCase

    init(useCase: NetworkingUseCase) {
        self.useCase = useCase
    }

    func fetchPacemakerFeeds(completion: @escaping ([FeedModel]) -> Void) {
        Task {
            do {
                let feeds = try await useCase.getPacemakerFeeds(cursor: 0, size: 5).map {
                    FeedModel(
                        userName: $0.userName,
                        category: $0.category,
                        feedImageURL: $0.feedImageURL,
                        feedContent: $0.feedContent,
                        likeCnt: $0.likeCount,
                        messageCnt: $0.messageCount
                    )
                }
                completion(feeds)
            } catch {
                completion([])
            }
        }
    }
}
