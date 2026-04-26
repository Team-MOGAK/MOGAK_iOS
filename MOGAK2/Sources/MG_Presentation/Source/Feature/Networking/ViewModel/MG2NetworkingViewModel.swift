import Foundation

final class MG2NetworkingViewModel {
    private let network: MG2NetworkingNetwork

    init(network: MG2NetworkingNetwork = .shared) {
        self.network = network
    }

    func fetchPacemakerFeeds(completion: @escaping ([FeedModel]) -> Void) {
        network.getPacemakerFeeds { result in
            switch result {
            case let .success(response):
                let feeds = response.result.compactMap { post -> FeedModel? in
                    guard let firstImage = post.imgUrls.first else { return nil }
                    return FeedModel(
                        userName: post.user.nickname,
                        category: post.user.job,
                        feedImageURL: firstImage,
                        feedContent: post.contents,
                        likeCnt: post.likeCnt,
                        messageCnt: post.comments.count
                    )
                }
                completion(feeds)
            case .failure:
                completion([])
            }
        }
    }
}
