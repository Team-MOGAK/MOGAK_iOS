//
//  Jogak_Router.swift
//  MOGAK
//
//  Created by 안세훈 on 12/24/23.
//

import Foundation
import Alamofire

let Accesstoken = "Bearer" + "  eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJpZCI6MSwiZW1haWwiOiJoeXVuMTIzQG5hdmVyLmNvbSIsInN1YiI6Imh5dW4xMjNAbmF2ZXIuY29tIiwiaWF0IjoxNzA3MjE0NzYzLCJleHAiOjE3MDcyMjE5NjN9.vG0GDgQSJv9znIH9zE7ElwhpSiyeWnk6oEVy3AlBduw"

let BaseURL = "https://mogak.shop:8080"

enum ApiRouter : URLRequestConvertible{
    
    case getModalartList                                    //모다라트 리스트 조회
    case detailModalart(modaratId: Int)                      //모다라트 디테일
    case getDetailMogakData(modaratId: Int)                 //모각 데이터 조회
    case getJogakList(mogakId : Int, DailyDate : String)       // 조각  조회
    case JogakSuccess(dailyJogakId : Int)                          //조각 성공
    case JogakFail(dailyJogakId : Int)                       //조각 실패
    case getJogakDailyCheck(DailyDate : String)             //일별 조각 조회
    case getAddJogakToday(jogakId : Int)                    //일일 조각 시작
    case getJogakMonth(startDay : String, endDay : String) //주, 월별 조각 조회
//    case getPost                                            // 회고록 조회
//    case makePost(mogakId : Int)                             //회고록 생성
    
    
    // url가르기
    var endPoint: String {
        switch self {
        case .getModalartList:
            return "/api/modarats"
        case .detailModalart(modaratId: let modaratId):
            return "/api/modarats/\(modaratId)"
        case .getDetailMogakData(let modaratId):
            return "/api/modarats/\(modaratId)/mogaks"
        case .getJogakList(let mogakId, let DailyDate):
            return "/api/modarats/mogaks/\(mogakId)/jogaks?date=" + DailyDate
        case .JogakSuccess(let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/success"
        case .getJogakDailyCheck(let DailyDate):
            return "/api/modarats/mogaks/jogaks/day?date=" + DailyDate
//        case .makePost(let mogakId):
//            return "/api/mogaks/\(mogakId)/posts"
//        case .addJogakDaily:
//            return ""
        case .getAddJogakToday(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/start"
        case .JogakFail(dailyJogakId: let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/fail"
        case .getJogakMonth(startDay: let startDay, endDay: let endDay):
            return "/api/modarats/mogaks/jogaks/routines?startDay=" + startDay+"&endDay=" + endDay
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        switch self {
//        default: return HTTPHeaders(["accept":"application/json", "Authorization" : Accesstoken])
        default: return HTTPHeaders(["accept":"application/json"])
        }
    }
    
    
    //어떤 방식(get, post, delete, update)
    var method: HTTPMethod {
        switch self {
        case .getModalartList, .detailModalart, .getJogakList, .getDetailMogakData, .getJogakDailyCheck, .getJogakMonth : return .get
//        case .makePost: return .post
        case .getAddJogakToday : return .post
        case .JogakSuccess: return .put
        case .JogakFail: return .put
        }
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = BaseURL.appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: url)!
        
        var request = URLRequest(url: urlString)
        request.method = method
        request.headers = headers
        
        switch self {
        case .getModalartList:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .detailModalart:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getDetailMogakData:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getJogakList:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .JogakSuccess:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getJogakDailyCheck:
            request = try URLEncoding.queryString.encode(request, with: parameters)
//        case .makePost(let data):
//            request = try JSONParameterEncoder().encode(data, into: request)
        case .getAddJogakToday(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .JogakFail:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getJogakMonth:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        //request = try URLEncoding.queryString.encode(request, with: parameters)
        //이 인코딩 방식은 GET 요청 또는 URL 쿼리 매개변수를 전송할 때 사용
        
        //request = try JSONParameterEncoder().encode(data, into: request)
        //이 인코딩 방식은 주로 POST 요청에서 사용되며, HTTP 요청 바디에 JSON 데이터를 넣어 전송할 때 사용
        return request
    }
}
