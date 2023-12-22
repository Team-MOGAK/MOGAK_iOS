//
//  MogakDetailNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import Foundation
import Alamofire

class MogakDetailNetwork: NSObject {
    static let shared = MogakDetailNetwork()
    func getAllMogakDetailJogaks(mogakId: Int, completionHandler: @escaping(Result<[JogakDetail]?, Error>) -> Void) {
        AF.request(MogakDetailRouter.getAllMogakDetailJogaks(mogakId))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: JogakDetailResponse.self) { (response: DataResponse<JogakDetailResponse, AFError>) in
                switch response.result {
                case .success(let jogakDetailResponse):
                    completionHandler(.success(jogakDetailResponse.result))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    let serializer = DataResponseSerializer(emptyResponseCodes: [])
    //MARK: - 모다라트 삭제 요청 API
    func deleteMogak(mogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
//        AF.request(ModalartRouter.delteModalart(modaratId: id), interceptor: CommonLoginManage())
        AF.request(MogakDetailRouter.deleteMogak(_mogakId: mogakId))
        .validate()
          .responseData(emptyResponseCodes: [200, 204, 205]) { response in
              switch response.result{
              case .failure(let error):
                  print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
                  completionHandler(.failure(error))
              case .success(_):
                  print(#fileID, #function, #line, "- data")
                  completionHandler(.success(true))
              }

          }
    }
    
    //MARK: - 모다라트 삭제 요청 API
    func deleteJogak(jogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
//        AF.request(ModalartRouter.delteModalart(modaratId: id), interceptor: CommonLoginManage())
        AF.request(MogakDetailRouter.deleteJogak(jogakId))
        .validate()
          .responseData(emptyResponseCodes: [200, 204, 205]) { response in
              switch response.result{
              case .failure(let error):
                  print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
                  completionHandler(.failure(error))
              case .success(_):
                  print(#fileID, #function, #line, "- data")
                  completionHandler(.success(true))
              }

          }
    }
    
}
