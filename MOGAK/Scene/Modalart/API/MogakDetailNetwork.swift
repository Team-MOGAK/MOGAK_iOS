//
//  MogakDetailNetwork.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import Foundation
import Alamofire

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

class MogakDetailNetwork: NSObject {
    static let shared = MogakDetailNetwork()
    func getAllMogakDetailJogaks(mogakId: Int, date: String, completionHandler: @escaping(Result<[JogakDetail]?, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyMogakDetailBridge.shared.getAllMogakDetailJogaks(mogakId: mogakId, date: date, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakDetailRouter.getAllMogakDetailJogaks(mogakId, date), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: JogakDetailResponse.self) { (response: DataResponse<JogakDetailResponse, AFError>) in
        //         switch response.result {
        //         case .success(let jogakDetailResponse):
        //             completionHandler(.success(jogakDetailResponse.result))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    let serializer = DataResponseSerializer(emptyResponseCodes: [])
    //MARK: - 모각 삭제 요청 API
    func deleteMogak(mogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyMogakDetailBridge.shared.deleteMogak(mogakId: mogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakDetailRouter.deleteMogak(_mogakId: mogakId), interceptor: CommonLoginManage())
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
    
    //MARK: - 모다라트 삭제 요청 API
    func deleteJogak(jogakId: Int, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if RegisterUserInfo.shared.loginState == .guest {
            return
        }

        // MOGAK2 bridge route (active)
        MG2LegacyMogakDetailBridge.shared.deleteJogak(jogakId: jogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(MogakDetailRouter.deleteJogak(jogakId), interceptor: CommonLoginManage())
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
    
}

#endif
