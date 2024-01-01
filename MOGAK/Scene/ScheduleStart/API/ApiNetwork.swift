//
//  ApiNetwork.swift
//  MOGAK
//
//  Created by 안세훈 on 12/24/23.
//

import Foundation
import Alamofire

class ApiNetwork{
    
    static let shared = ApiNetwork()
    
//MARK: - 모다라트 리스트 조회
    func getModalartList( completionHandler: @escaping (Result<[ModalartList]?, Error>) -> Void) {
    //        AF.request(JogakRouter.getModalartList, interceptor: CommonLoginManage())
            AF.request(ApiRouter.getModalartList)
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
//MARK: - 모다라트 상세 내용 API
        func getDetailModalartInfo(modalartId: Int, completionHandler: @escaping (Result<ModalartInfo?, Error>) -> Void) {
    //        AF.request(ModalartRouter.detailModalart(modaratId: modalartId), interceptor: CommonLoginManage())
            AF.request(ApiRouter.detailModalart(modaratId: modalartId))
                .validate(statusCode: 200..<300)
                .responseDecodable(of: ModalartDetailInfo.self) { (response: DataResponse<ModalartDetailInfo, AFError>) in
                    switch response.result {
                    case .failure(let error):
                        print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                        completionHandler(.failure(error))
                    case .success(let data):
                        //print(#fileID, #function, #line, "- data: \(String(describing: data.result?.title))")
                        completionHandler(.success(data.result))
                    }
                }
        }
        
        func getDetailMogakData(modalartId: Int, completionHandler: @escaping((Result<DetailMogakResponse?, Error>) -> Void)) {
            AF.request(ApiRouter.getDetailMogakData(modaratId: modalartId))
                .validate(statusCode: 200..<300)
                .responseDecodable(of: DetailMogakResponse.self) { (response: DataResponse<DetailMogakResponse, AFError>) in
                    switch response.result {
                    case .success(let data):
                        completionHandler(.success(data))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
        }
    
//MARK: - 조각 조회
    func getAllMogakDetailJogaks(mogakId: Int, completionHandler: @escaping(Result<[JogakDetail]?, Error>) -> Void) {
        AF.request(ApiRouter.getJogakList(mogakId: mogakId))
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
    
//MARK: - 일일 조각 조회
//    func getJogakToday(completionHandler: @escaping (Result<[JogakConstants]?, Error>) -> Void) {
//        AF.request(JogakRouter.JogakToday)
//            .validate(statusCode: 200..<300)
//            .responseDecodable(completionHandler: <#T##(DataResponse<Decodable, AFError>) -> Void#>)
//        let request = AF.request(ApiConstants.JogakTodayURL, headers: headers)
//        
//        request.responseDecodable { (data: DataResponse<JogakToday, AFError>) in
//            switch data.result {
//            case .success(let jogakToday):
//                // API 조회 성공
//                if jogakToday.code == "success" { // 성공적으로 조회된 경우
//                    if let jogakList = jogakToday.dailyJogaks {
//                        // jogakList를 사용하여 필요한 작업 수행
//                        print(jogakToday)
//                        for jogak in jogakList {
//                            if jogak.dailyJogakId == 4 {
//                                // jogakId가 4인 경우에 대한 처리
//                                print("Found Jogak with ID 4:")
//                                print("Jogak ID: \(jogak.dailyJogakId)")
//                                print("Mogak Title: \(jogak.mogakTitle)")
//                                print("Category: \(jogak.category)")
//                                print("Title: \(jogak.title)")
//                                // 여기서 원하는 동작 수행
//                                // 예: 특정 함수 호출 또는 화면 전환 등
//                            }
//                        }
//                    } else {
//                        // jogaks가 nil인 경우 (데이터 없음)
//                        print("No jogaks available for today")
//                        print(jogakToday)
//                    }
//                } else {
//                    // 서버로부터 오류 응답이 온 경우
//                    print("Error: \(jogakToday.code), \(jogakToday.message)")
//                    
//                }
//                
//            case .failure(let error):
//                // 오류가 발생한 경우 처리합니다.
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//    }
    //MARK: -

}

