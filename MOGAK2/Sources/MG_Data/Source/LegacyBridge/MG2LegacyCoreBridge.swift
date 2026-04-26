import Foundation
import Alamofire

final class MG2LegacyCoreBridge {

    static let shared = MG2LegacyCoreBridge()

    private init() {}

    func get<T: Decodable>(url: String, parameters: [String: Any]? = nil, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: T.self) { response in
                completion(response.result)
            }
    }

    func get<T: Decodable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        completion: @escaping (Result<T, AFError>) -> Void
    ) {
        AF.request(url, method: .get, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                completion(response.result)
            }
    }

    func post(url: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping (DataResponse<Data?, AFError>) -> Void) {
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                completion(response)
            }
    }
}
