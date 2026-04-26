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
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.createMogak(data: data, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.createMogak(data: data), interceptor: CommonLoginManage())
        //     .responseDecodable(of: CreateMogakResponse.self) { (response: DataResponse<CreateMogakResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
    
    // MARK: - 모각수정 API
    func editMogak(data: EditMogakRequestMainData, completionHandler: @escaping (Result<EditMogakMainData, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.editMogak(data: data, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.editMogak(data: data), interceptor: CommonLoginManage())
        //     .responseDecodable(of: EditMogakResponse.self) { (response: DataResponse<EditMogakResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
    
    // MARK: - 모각삭제 API
    func deleteMogak(mogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        print(#fileID, #function, #line, "- mogakId: \(mogakId)")
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.deleteMogak(mogakId: mogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.deleteMogak(mogakId: mogakId)).validate()
        //     .responseData(emptyResponseCodes: [200, 204, 205]) { response in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success:
        //             completionHandler(.success(true))
        //         }
        //     }
    }
    
    // MARK: - 조각생성 API
    func createJogak(data: CreateJogakRequestMainData, completionHandler: @escaping (Result<CreateJogakMainData, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.createJogak(data: data, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.createJogak(data: data), interceptor: CommonLoginManage())
        //     .responseDecodable(of: CreateJogakResponse.self) { (response: DataResponse<CreateJogakResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
    
    // MARK: - 조각수정 API
    func editJogak(data: EditJogakRequestMainData, jogakId: Int, completionHandler: @escaping (Result<EditJogakResponse, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.editJogak(data: data, jogakId: jogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.editJogak(data: data, jogakId: jogakId), interceptor: CommonLoginManage())
        //     .responseDecodable(of: EditJogakResponse.self) { (response: DataResponse<EditJogakResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data))
        //         }
        //     }
    }
    
    // MARK: - 조각삭제 API
    func deleteJogak(jogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        print(#fileID, #function, #line, "- jogakId: \(jogakId)")
        // MOGAK2 bridge route (active)
        MG2LegacyHistoryBridge.shared.deleteJogak(jogakId: jogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakRouter.deleteJogak(jogakId: jogakId), interceptor: CommonLoginManage()).validate()
        //     .responseData(emptyResponseCodes: [200, 204, 205]) { response in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success:
        //             completionHandler(.success(true))
        //         }
        //     }
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
