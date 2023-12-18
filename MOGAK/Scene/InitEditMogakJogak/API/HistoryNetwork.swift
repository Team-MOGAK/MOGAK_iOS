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
                    print(#fileID, #function, #line, "- data mogakId: \(data.result.mogakId)")
                    completionHandler(.success(data.result))
                }
            }
    }
    
    // MARK: - 모각수정 API
    func editMogak(data: MogakMainData, completionHandler: @escaping (Result<EditMogakMainData, Error>) -> Void) {
        AF.request(MogakRouter.editMogak(data: data))
            .responseDecodable(of: EditMogakResponse.self) {
                (response: DataResponse<EditMogakResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data titla: \(data.result.mogakId)") //수정 필요
                    completionHandler(.success(data.result))
                }
            }
    }
    
    // MARK: - 모각삭제 API
//    func deleteMogak(mogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
//        print(#fileID, #function, #line, "- mogakId: \(mogakId)")
//        AF.request(MogakRouter.deleteMogak(mogakId: mogakId)).validate()
//            .responseData(emptyResponseCodes: [200, 204, 205]) { response in
//                switch response.result {
//                case .failure(let error):
//                    print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
//                    completionHandler(.failure(error))
//                case .success(_):
//                    print(#fileID, #function, #line, "- data")
//                    completionHandler(.success(true))
//                }
//            }
//    }
}

//class MemoirNetwork {
//    // MARK: - 회고록 리스트 조회
//    func getMemoirTable(mogakId: Int, completionHandler: @escaping (Result<[MemoirContent]?, Error>) -> Void) {
//        AF.request(MemoirRouter.getMemoirList(mogakId: mogakId))
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: MemoirListResponse.self) {
//                (response: DataResponse<MemoirListResponse, AFError>) in
//                switch response.result {
//                case .failure(let error):
//                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
//                    completionHandler(.failure(error))
//                case .success(let data):
//                    print(#fileID, #function, #line, "- data: \(String(describing: data.memoirListResult?.content[0]))")
//                    completionHandler(.success(data.memoirListResult?.content))
//                }
//                
//            }
//    }
//}
