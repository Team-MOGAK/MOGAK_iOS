//
//  NetworkService.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/24.
//

import Foundation
import Alamofire

#if false
// Legacy MOGAK1 implementation (inactive after migration/deprecation in MOGAK2).

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://mogak.shop:8081"
    
    private init() { }
    
    // MARK: - get
    func get<T: Decodable>(path: String, parameters: [String: Any]? = nil, completion: @escaping (Swift.Result<T, AFError>) -> Void) {
        let url = baseURL + path

        // MOGAK2 bridge route (active)
        MG2LegacyCoreBridge.shared.get(url: url, parameters: parameters, completion: completion)

        // Legacy MOGAK1 route (inactive)
        // AF.request(url, method: .get, parameters: parameters)
        //     .validate()
        //     .responseDecodable(of: T.self) { response in
        //         completion(response.result)
        //     }
    }
    
    // MARK: - post
    func post(path: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping (DataResponse<Data?, AFError>) -> Void) {
        let url = baseURL + path

        // MOGAK2 bridge route (active)
        MG2LegacyCoreBridge.shared.post(url: url, parameters: parameters, headers: headers, completion: completion)

        // Legacy MOGAK1 route (inactive)
        // AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        //     .validate()
        //     .response { response in
        //         completion(response)
        //     }
    }
}

#endif
