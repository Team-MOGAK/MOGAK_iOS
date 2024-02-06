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
    func getModalartList( completionHandler: @escaping (Result<[ScheduleModalartList]?, Error>) -> Void) {
                AF.request(ApiRouter.getModalartList, interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getModalartList)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ScheduleModalartListResponse.self) { (response: DataResponse<ScheduleModalartListResponse, AFError>) in
                switch response.result {
                case .failure(let error):
                    //print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    completionHandler(.success(data.modalartList))
                }
            }
    }
    //MARK: - 모다라트 상세 내용 API
    func getDetailModalartInfo(modalartId: Int, completionHandler: @escaping (Result<ScheduleModalartInfo?, Error>) -> Void) {
                AF.request(ApiRouter.detailModalart(modaratId: modalartId), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.detailModalart(modaratId: modalartId))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ScheduleModalartDetailInfo.self) { (response: DataResponse<ScheduleModalartDetailInfo, AFError>) in
                switch response.result {
                case .failure(let error):
                    //print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                case .success(let data):
                    //print(#fileID, #function, #line, "- data: \(String(describing: data.result?.title))")
                    completionHandler(.success(data.result))
                }
            }
    }
    //MARK: - 모각 조회
    func getDetailMogakData(modalartId: Int, completionHandler: @escaping((Result<ScheduleDetailMogakResponse?, Error>) -> Void)) {
                AF.request(ApiRouter.getDetailMogakData(modaratId: modalartId), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getDetailMogakData(modaratId: modalartId))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ScheduleDetailMogakResponse.self) { (response: DataResponse<ScheduleDetailMogakResponse, AFError>) in
                switch response.result {
                case .success(let data):
                    completionHandler(.success(data))
                case .failure(let error):
                    completionHandler(.failure(error))
                    debugPrint(response)
                    print("에러")
                }
            }
    }
    
    //MARK: - 모각에 대응하는 조각 조회
    func getAllMogakDetailJogaks(mogakId: Int, DailyDate: String, completionHandler: @escaping(Result<[ScheduleJogakDetail]?, Error>) -> Void) {
                AF.request(ApiRouter.getJogakList(mogakId: mogakId, DailyDate: DailyDate), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getJogakList(mogakId: mogakId, DailyDate: DailyDate))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ScheduleJogakDetailResponse.self) { (response: DataResponse<ScheduleJogakDetailResponse, AFError>) in
                switch response.result {
                case .success(let jogakDetailResponse):
                    completionHandler(.success(jogakDetailResponse.result))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    //MARK: - 일일 조각 조회
    func getCheckDailyJogak(DailyDate : String, completionHandler : @escaping(Result<[JogakDailyCheck]?, Error>)-> Void) {
                AF.request(ApiRouter.getJogakDailyCheck(DailyDate: DailyDate), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getJogakDailyCheck(DailyDate: DailyDate))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: JogakDailyCheck.self) { response in
                switch response.result {
                case .success(let jogakDailyResponse):
                    completionHandler(.success([jogakDailyResponse]))
                    //print("ApiNetwork.swift에서 success뜸", jogakDailyResponse.result)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    //MARK: - 일일 조각 시작
    func getAddJogakDaily(jogakId : Int, completionHandler : @escaping(Result<[JogakDailyAdd]?, Error>)-> Void) {
                AF.request(ApiRouter.getAddJogakToday(jogakId: jogakId), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getAddJogakToday(jogakId: jogakId))
            .validate(statusCode: 200..<500)
            .responseDecodable(of: JogakDailyAdd.self) { response in
                switch response.result {
                case .success(let jogakAddResponse):
                    completionHandler(.success([jogakAddResponse]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    //MARK: - 조각 실패
    func getJogakFail(dailyJogakId : Int, completionHandler : @escaping(Result<[JogakFail]?, Error>)-> Void) {
                AF.request(ApiRouter.JogakFail(dailyJogakId: dailyJogakId), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.JogakFail(dailyJogakId: dailyJogakId))
            .validate(statusCode: 200..<500)
            .responseDecodable(of: JogakFail.self) { response in
                switch response.result {
                case .success(let jogakfailResponse):
                    completionHandler(.success([jogakfailResponse]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    //MARK: - 조각 성공
    func getJogakSuccess(dailyJogakId : Int, completionHandler : @escaping(Result<[JogakSuccess]?, Error>)-> Void) {
                AF.request(ApiRouter.JogakSuccess(dailyJogakId: dailyJogakId), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.JogakSuccess(dailyJogakId: dailyJogakId))
            .validate(statusCode: 200..<500)
            .responseDecodable(of: JogakSuccess.self) { response in
                switch response.result {
                case .success(let JogakSuccessResponse):
                    completionHandler(.success([JogakSuccessResponse]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    //MARK: - 주,월간 조각 조회
    func getJogakMonth(startDay: String, endDay: String, completionHandler: @escaping (Result<[JogakMonth], Error>) -> Void) {
                AF.request(ApiRouter.getJogakMonth(startDay: startDay, endDay: endDay), interceptor: CommonLoginManage())
//        AF.request(ApiRouter.getJogakMonth(startDay: startDay, endDay: endDay))
            .validate(statusCode: 200..<400)
            .responseDecodable(of: JogakMonth.self) { response in
                switch response.result {
                case .success(let jogakMonthResponse):
                    completionHandler(.success([jogakMonthResponse]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    
    
    
}
