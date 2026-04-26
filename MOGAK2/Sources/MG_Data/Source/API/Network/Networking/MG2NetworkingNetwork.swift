import Foundation
import Alamofire

final class MG2NetworkingNetwork {
    static let shared = MG2NetworkingNetwork()
    private init() {}

    func getPacemakerFeeds(cursor: Int = 0,
                           size: Int = 5,
                           completion: @escaping (Result<PacemakerFeedsResponse, AFError>) -> Void) {
        // MOGAK2 route (active)
        AF.request(MG2NetworkingRouter.pacemakerFeeds(cursor: cursor, size: size))
            .responseDecodable(of: PacemakerFeedsResponse.self) { response in
                completion(response.result)
            }

        // MOGAK1 legacy route (inactive)
        // let headers: HTTPHeaders = ["Authorization": "Bearer <token>"]
        // let params: Parameters = ["cursor": cursor, "size": size]
        // AF.request("http://43.200.36.231:8080/api/posts/pacemakers",
        //            method: .get,
        //            parameters: params,
        //            encoding: URLEncoding.default,
        //            headers: headers)
        //   .responseDecodable(of: PacemakerFeedsResponse.self) { response in
        //       completion(response.result)
        //   }
    }
}
