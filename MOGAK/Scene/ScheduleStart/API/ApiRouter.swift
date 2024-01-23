//
//  Jogak_Router.swift
//  MOGAK
//
//  Created by 안세훈 on 12/24/23.
//

import Foundation
import Alamofire

let Accesstoken = "Bearer" + " eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJpZCI6MSwiZW1haWwiOiJoeXVuMTIzQG5hdmVyLmNvbSIsInN1YiI6Imh5dW4xMjNAbmF2ZXIuY29tIiwiaWF0IjoxNzA2MDMyODU2LCJleHAiOjE3MDYwNDAwNTZ9.NXDoZkTWwN-obv-MQG_lN13pQ0eiBgQaQXoGww0VAaY"

let BaseURL = "https://mogak.shop:8080"

enum ApiRouter : URLRequestConvertible{
    
    case getModalartList                          //모다라트 리스트 조회
    case detailModalart(modaratId: Int)            //모다라트 디테일
    case getDetailMogakData(modaratId: Int)       //모각 데이터 조회
    case getJogakList(mogakId : Int)              // 조각  조회
    case JogakSuccess(jogakId : Int)                //조각 성공
    case getJogakDailyCheck(DailyDate : String)    //일별 조각 조회
//    case addJogakDaily
//    case getPost                                  // 회고록 조회
//    case makePost(mogakId : Int)                   //회고록 생성
    
    
    // url가르기
    var endPoint: String {
        switch self {
        case .getModalartList:
            return "/api/modarats"
        case .detailModalart(modaratId: let modaratId):
            return "/api/modarats/\(modaratId)"
        case .getDetailMogakData(let modaratId):
            return "/api/modarats/\(modaratId)/mogaks"
        case .getJogakList(let mogakId):
            return "/api/modarats/mogaks/\(mogakId)/jogaks"
        case .JogakSuccess(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/success"
        case .getJogakDailyCheck(let DailyDate):
            return "/api/modarats/mogaks/jogaks/day?day=" + DailyDate
//        case .makePost(let mogakId):
//            return "/api/mogaks/\(mogakId)/posts"
//        case .addJogakDaily:
//            return ""
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        switch self {
        default: return HTTPHeaders(["accept":"application/json", "Authorization" : Accesstoken])
        }
    }
    
    
    //어떤 방식(get, post, delete, update)
    var method: HTTPMethod {
        switch self {
        case .getModalartList, .detailModalart, .getJogakList, .getDetailMogakData, .getJogakDailyCheck : return .get
//        case .makePost: return .post
        case .JogakSuccess: return .put
//        case .addJogakDaily:
//            <#code#>
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
//        case .addJogakDaily:
//            <#code#>
        }
        
        return request
    }
}
