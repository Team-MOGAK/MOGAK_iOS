//
//  ModalartNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/16.
//

import Foundation
import Alamofire

class ModalartNetwork {
    static let shared = ModalartNetwork()
    //MARK: - 모다라트 상세 내용 API
    func getDetailModalartInfo(modalartId: Int = 4, completionHandler: @escaping (Result<ModalartInfo?, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.getDetailModalartInfo(modalartId: modalartId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.detailModalart(modaratId: modalartId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ModalartDetailInfo.self) { (response: DataResponse<ModalartDetailInfo, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
    
    func getDetailMogakData(modalartId: Int, completionHandler: @escaping((Result<DetailMogakResponse?, Error>) -> Void)) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.getDetailMogakData(modalartId: modalartId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.getDetailMogakData(modaratId: modalartId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: DetailMogakResponse.self) { (response: DataResponse<DetailMogakResponse, AFError>) in
        //         switch response.result {
        //         case .success(let data):
        //             completionHandler(.success(data))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 모다라트 리스트 조회 API
    func getModalartList( completionHandler: @escaping (Result<[ModalartList]?, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.getModalartList(completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.getModalartList, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ModalartListResponse.self) { (response: DataResponse<ModalartListResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.modalartList))
        //         }
        //     }
    }
    
    //MARK: - 모다라트 생성 요청 API
    func createDetailModalart(data: ModalartMainData, completionHandler: @escaping (Result<ModalartMainData, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.createModalart(data: data, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.createModalrt(data: data), interceptor: CommonLoginManage())
        //     .responseDecodable(of: CreateAndEditModalartResponse.self) { (response: DataResponse<CreateAndEditModalartResponse, AFError>)  in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
    
    let serializer = DataResponseSerializer(emptyResponseCodes: [])
    //MARK: - 모다라트 삭제 요청 API
    func deleteModalart(id: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.deleteModalart(id: id, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.delteModalart(modaratId: id), interceptor: CommonLoginManage())
        // .validate()
        // .responseData(emptyResponseCodes: [200, 204, 205]) { response in
        //     switch response.result {
        //     case .failure(let error):
        //         completionHandler(.failure(error))
        //     case .success:
        //         completionHandler(.success(true))
        //     }
        // }
    }
    
    
    
    func editModalart(data: ModalartMainData, completionHandler: @escaping(Result<ModalartMainData, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyModalartBridge.shared.editModalart(data: data, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ModalartRouter.editModalart(data: data), interceptor: CommonLoginManage())
        //     .responseDecodable(of: CreateAndEditModalartResponse.self) { (response: DataResponse<CreateAndEditModalartResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }
}
