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
                    //print(#fileID, #function, #line, "- data mogakId: \(data.result.mogakId)")
                    print(#fileID, #function, #line, "- data mogakId: \(data.result.id)")
                    print(#fileID, #function, #line, "- data state: \(data.result.state)")
                    print(#fileID, #function, #line, "- data bigCateogry id: \(String(describing: data.result.bigCategory.id))")
                    print(#fileID, #function, #line, "- data bigCategory name: \(String(describing: data.result.bigCategory.name))")
                    print(#fileID, #function, #line, "- data color: \(data.result.color)")
                    print(#fileID, #function, #line, "- data startAt: \(data.result.startAt)")
                    print(#fileID, #function, #line, "- data endAt: \(data.result.endAt)")
                    completionHandler(.success(data.result))
                }
            }
    }
    
    // MARK: - 모각수정 API
    func editMogak(data: EditMogakRequestMainData, completionHandler: @escaping (Result<EditMogakMainData, Error>) -> Void) {
        AF.request(MogakRouter.editMogak(data: data))
            .responseDecodable(of: EditMogakResponse.self) {
                (response: DataResponse<EditMogakResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data titla: \(data.result.mogakId)")
                    print(#fileID, #function, #line, "- data updatedAt: \(data.result.updatedAt)")//수정 필요
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
    
    // MARK: - 조각생성 API
    func createJogak(data: CreateJogakRequestMainData, completionHandler: @escaping (Result<CreateJogakMainData, Error>) -> Void) {
        AF.request(MogakRouter.createJogak(data: data))
            .responseDecodable(of: CreateJogakResponse.self) {
                (response: DataResponse<CreateJogakResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data jogakId: \(data.result.jogakId)")
                    print(#fileID, #function, #line, "- data mogakTitle: \(data.result.mogakTitle)")
                    print(#fileID, #function, #line, "- data category: \(data.result.category)")
                    print(#fileID, #function, #line, "- data isRoutine: \(data.result.isRoutine)")
                    print(#fileID, #function, #line, "- data title: \(data.result.title)")
                    print(#fileID, #function, #line, "- data start: \(data.result.startDate)")
                    print(#fileID, #function, #line, "- data end: \(data.result.endDate)")
                    completionHandler(.success(data.result))
                }
            }
    }
    
    // MARK: - 조각수정 API
    func editJogak(data: EditJogakRequestMainData, jogakId: Int, completionHandler: @escaping (Result<EditJogakResponse, Error>) -> Void) {
        AF.request(MogakRouter.editJogak(data: data, jogakId: jogakId))
            .responseDecodable(of: EditJogakResponse.self) {
                (response: DataResponse<EditJogakResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data: \(data.message)")
                    completionHandler(.success(data))
                }
            }
    }
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
