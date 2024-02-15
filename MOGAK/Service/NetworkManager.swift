//
//  NetworkService.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/24.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://mogak.shop:8081"
    
    private init() { }
    
    // MARK: - get
    func get<T: Decodable>(path: String, parameters: [String: Any]? = nil, completion: @escaping (Swift.Result<T, AFError>) -> Void) {
        let url = baseURL + path
        
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: T.self) { response in
                completion(response.result)
            }
    }
    
    // MARK: - post
    func post(path: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping (DataResponse<Data?, AFError>) -> Void) {
        let url = baseURL + path
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                completion(response)
            }
    }
}
