//
//  HistoryNetwork.swift
//  MOGAK
//
//  Created by 이재혁 on 12/6/23.
//

import Foundation
import Alamofire

class MogakNetwork {
    // MARK: - 모각(작은목표)생성 API
    func createMogak(data: MogakMainData, completionHandler: @escaping (Result<CreateMogakMainData, Error>) -> Void) {
        AF.request(MogakRouter.createMogak(data: data))
            .responseDecodable(of: CreateMogakResponse.self) {
                (response: DataResponse<CreateMogakResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data title: \(data.result.title)")
//                    print(#fileID, #function, #line, "- data bigCategory: \(data.result.bigCategory)")
//                    print(#fileID, #function, #line, "- data smallCategory: \(data.result.smallCategory)")
//                    print(#fileID, #function, #line, "- data startAt: \(data.result.startAt)")
//                    print(#fileID, #function, #line, "- data endAt: \(data.result.endAt)")
//                    print(#fileID, #function, #line, "- data color: \(data.result.color)")
                    print(#fileID, #function, #line, "- data mogakId: \(data.result.mogakId)")
                    completionHandler(.success(data.result))
                }
            }
    }
}
