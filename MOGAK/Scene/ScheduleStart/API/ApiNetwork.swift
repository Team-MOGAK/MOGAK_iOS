//
//  ApiNetwork.swift
//  MOGAK
//
//  Created by 안세훈 on 12/24/23.
//

import Foundation
import Alamofire

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

class ApiNetwork{
    
    static let shared = ApiNetwork()
    
    //MARK: - 모다라트 리스트 조회
    func getModalartList(completionHandler: @escaping (Result<[ScheduleModalartList]?, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        ScheduleStartLegacyBridge.shared.getModalartList(completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getModalartList, interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ScheduleModalartListResponse.self) { (response: DataResponse<ScheduleModalartListResponse, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.modalartList))
        //         }
        //     }
    }

    //MARK: - 모다라트 상세 내용 API
    func getDetailModalartInfo(modalartId: Int, completionHandler: @escaping (Result<ScheduleModalartInfo?, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        ScheduleStartLegacyBridge.shared.getModalartDetail(modalartId: modalartId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.detailModalart(modaratId: modalartId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ScheduleModalartDetailInfo.self) { (response: DataResponse<ScheduleModalartDetailInfo, AFError>) in
        //         switch response.result {
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         case .success(let data):
        //             completionHandler(.success(data.result))
        //         }
        //     }
    }

    //MARK: - 모각 조회
    func getDetailMogakData(modalartId: Int, completionHandler: @escaping((Result<ScheduleDetailMogakResponse?, Error>) -> Void)) {
        // MOGAK2 bridge route (active)
        ScheduleStartLegacyBridge.shared.getDetailMogakData(modalartId: modalartId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getDetailMogakData(modaratId: modalartId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ScheduleDetailMogakResponse.self) { (response: DataResponse<ScheduleDetailMogakResponse, AFError>) in
        //         switch response.result {
        //         case .success(let data):
        //             completionHandler(.success(data))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //             debugPrint(response)
        //             print("에러")
        //         }
        //     }
    }
    
    //MARK: - 모각에 대응하는 조각 조회
    func getAllMogakDetailJogaks(mogakId: Int, DailyDate: String, completionHandler: @escaping(Result<[ScheduleJogakDetail]?, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleJogakList(mogakId: mogakId, dailyDate: DailyDate, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getJogakList(mogakId: mogakId, DailyDate: DailyDate), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: ScheduleJogakDetailResponse.self) { (response: DataResponse<ScheduleJogakDetailResponse, AFError>) in
        //         switch response.result {
        //         case .success(let jogakDetailResponse):
        //             completionHandler(.success(jogakDetailResponse.result))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 일일 조각 조회
    func getCheckDailyJogak(DailyDate : String, completionHandler : @escaping(Result<[JogakDailyCheck]?, Error>)-> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleDailyCheck(dailyDate: DailyDate, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getJogakDailyCheck(DailyDate: DailyDate), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<300)
        //     .responseDecodable(of: JogakDailyCheck.self) { response in
        //         switch response.result {
        //         case .success(let jogakDailyResponse):
        //             completionHandler(.success([jogakDailyResponse]))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    //MARK: - 일일 조각 시작
    func getAddJogakDaily(jogakId: Int, completionHandler: @escaping(Result<[JogakDailyStartResponse]?, Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleAddJogakDaily(jogakId: jogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getAddJogakToday(jogakId: jogakId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<500)
        //     .responseDecodable(of: JogakDailyStart.self) { response in
        //         switch response.result {
        //         case .success:
        //             completionHandler(.success(nil))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 일일 조각 디테일 조회
    func getdailyJogakDetail(jogakId: Int, completionHandler: @escaping(Result<DailyJogakDetail?, Error>) -> Void){
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleDailyJogakDetail(jogakId: jogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getdailyJogakDetail(jogakId: jogakId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<500)
        //     .responseDecodable(of: DailyJogakDetail.self) { response in
        //         switch response.result {
        //         case .success(let data):
        //             completionHandler(.success(data))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }

    //MARK: - 조각 실패
    func getJogakFail(dailyJogakId : Int, completionHandler : @escaping(Result<[JogakFail]?, Error>)-> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleJogakFail(dailyJogakId: dailyJogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.JogakFail(dailyJogakId: dailyJogakId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<500)
        //     .responseDecodable(of: JogakFail.self) { response in
        //         switch response.result {
        //         case .success(let jogakfailResponse):
        //             completionHandler(.success([jogakfailResponse]))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 조각 성공
    func getJogakSuccess(dailyJogakId : Int, completionHandler : @escaping(Result<[JogakSuccess]?, Error>)-> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleJogakSuccess(dailyJogakId: dailyJogakId, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.JogakSuccess(dailyJogakId: dailyJogakId), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<500)
        //     .responseDecodable(of: JogakSuccess.self) { response in
        //         switch response.result {
        //         case .success(let jogakSuccessResponse):
        //             completionHandler(.success([jogakSuccessResponse]))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    //MARK: - 주,월간 조각 조회
    func getJogakMonth(startDay: String, endDay: String, completionHandler: @escaping (Result<[JogakMonth], Error>) -> Void) {
        // MOGAK2 bridge route (active)
        MG2LegacyScheduleStartBridge.shared.scheduleJogakMonth(startDay: startDay, endDay: endDay, completion: completionHandler)

        // Legacy MOGAK1 route (inactive)
        // AF.request(ApiRouter.getJogakMonth(startDay: startDay, endDay: endDay), interceptor: CommonLoginManage())
        //     .validate(statusCode: 200..<400)
        //     .responseDecodable(of: JogakMonth.self) { response in
        //         switch response.result {
        //         case .success(let jogakMonthResponse):
        //             completionHandler(.success([jogakMonthResponse]))
        //         case .failure(let error):
        //             completionHandler(.failure(error))
        //         }
        //     }
    }
    
    
    
    
}

#endif
