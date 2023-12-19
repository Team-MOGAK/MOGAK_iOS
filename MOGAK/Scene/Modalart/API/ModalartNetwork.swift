//
//  ModalartNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/16.
//

import Foundation
import Alamofire

class ModalartNetwork {
    //MARK: - 모다라트 상세 내용 API
    func getDetailModalartInfo(modalartId: Int = 4, completionHandler: @escaping (Result<ModalartInfo?, Error>) -> Void) {

//        AF.request(ModalartRouter.detailModalart(modaratId: modalartId), interceptor: CommonLoginManage())
        AF.request(ModalartRouter.detailModalart(modaratId: modalartId))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ModalartDetailInfo.self) { (response: DataResponse<ModalartDetailInfo, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data: \(String(describing: data.result?.title))")
                    completionHandler(.success(data.result))
                }
            }
    }
    
    //MARK: - 모다라트 리스트 조회 API
    func getModalartList( completionHandler: @escaping (Result<[ModalartList]?, Error>) -> Void) {
//        AF.request(ModalartRouter.getModalartList, interceptor: CommonLoginManage())
        AF.request(ModalartRouter.getModalartList)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ModalartListResponse.self) { (response: DataResponse<ModalartListResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    completionHandler(.success(data.modalartList))
                }
            }
    }
    
    //MARK: - 모다라트 생성 요청 API
    func createDetailModalart(data: ModalartMainData, completionHandler: @escaping (Result<ModalartMainData, Error>) -> Void) {
        
//        AF.request(ModalartRouter.createModalrt(data: data), interceptor: CommonLoginManage())
        AF.request(ModalartRouter.createModalrt(data: data))
            .responseDecodable(of: CreateAndEditModalartResponse.self) { (response: DataResponse<CreateAndEditModalartResponse, AFError>)  in
                switch response.result {
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    print(#fileID, #function, #line, "- data title: \(data.result.title)")
                    print(#fileID, #function, #line, "- data id: \(data.result.id)")
                    completionHandler(.success(data.result))
                }
            }
    }
    
    let serializer = DataResponseSerializer(emptyResponseCodes: [])
    //MARK: - 모다라트 삭제 요청 API
    func deleteModalart(id: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        print(#fileID, #function, #line, "- id:\(id)")
//        AF.request(ModalartRouter.delteModalart(modaratId: id), interceptor: CommonLoginManage())
        AF.request(ModalartRouter.delteModalart(modaratId: id))
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
    
    func editModalart(data: ModalartMainData, completionHandler: @escaping(Result<ModalartMainData, Error>) -> Void) {
//        AF.request(ModalartRouter.editModalart(data: data), interceptor: CommonLoginManage())
        AF.request(ModalartRouter.editModalart(data: data))
            .responseDecodable(of: CreateAndEditModalartResponse.self) { (response: DataResponse<CreateAndEditModalartResponse, AFError>) in
                switch response.result {
                case .failure(let error) :
                    print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                case .success(let data):
                    completionHandler(.success(data.result))
                }
            }
        
    }
}
