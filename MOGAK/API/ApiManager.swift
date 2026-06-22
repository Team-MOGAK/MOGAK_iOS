//
//  ApiManager.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation
import Alamofire

#if false
// Legacy MOGAK1 implementation (inactive after migration/deprecation in MOGAK2).
//let BASE_URL = "https://mogak.shop:8080/"

class ApiManager {
    
    static let shared = ApiManager()
    
    private init() {}
    
    enum APIError: Error {
        case invalidURL
        case requestFailed
        case invalidResponse
        case statusCode(Int)
    }
    
    enum APIResult<T> {
        case success(T)
        case failure(APIError)
    }
    
    struct EmptyResponse: Decodable {} // 빈 데이터 구조체
    
    func getData<T: Decodable>(url: String, parameters: [String: Any]? = nil, completion: @escaping (APIResult<T>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyCoreBridge.shared.get(url: url, parameters: parameters) { (result: Result<T, AFError>) in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                let statusCode = error.responseCode ?? 0
                completion(.failure(.statusCode(statusCode)))
            }
        }

        // Legacy MOGAK1 route (inactive)
        // AF.request(url, method: .get, parameters: parameters)
        //     .validate()
        //     .responseDecodable(of: T.self) { response in
        //         let statusCode = response.response?.statusCode ?? 0
        //         switch response.result {
        //         case .success(let value):
        //             completion(.success(value))
        //         case .failure:
        //             completion(.failure(.statusCode(statusCode)))
        //         }
        //     }
    }
    
}



#endif
