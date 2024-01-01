//
//  Jogak_Router.swift
//  MOGAK
//
//  Created by 안세훈 on 12/24/23.
//

import Foundation
import Alamofire

let Accesstoken = "Bearer" + " eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJ1c2VyUGsiOiIxIiwiaWF0IjoxNjkyNzIyNDEwLCJleHAiOjE3MjQyNTg0MTB9.sqb4ioXK5fTGz7CRzL1ZBZ9yxDvBwIUfY-Azbo3aVuM"

let BaseURL = "https://mogak.shop:8081"

enum ApiRouter : URLRequestConvertible{
    
    
    case getModalartList                       //모다라트 리스트 조회
    case detailModalart(modaratId: Int)         //모다라트 디테일
    case getDetailMogakData(modaratId: Int)     //모각 데이터 조회
    case getJogakList(mogakId : Int)    // 조각  조회
    case JogakSuccess(jogakId : Int)      //조각 성공
    //case JogakToday                     //일일 조각 조회
    //case getPost                        // 회고록 조회
    
    case makePost(mogakId : Int)            //회고록 생성
    
    
    // url가르기
    var endPoint: String {
        switch self {
        case .getModalartList:
            return "/api/modarats"
        case .getDetailMogakData(let modaratId):
            return "/api/modarats/\(modaratId)/mogaks"
        case .getJogakList(let mogakId):
            return "/api/modarats/mogaks/\(mogakId)/jogaks"
        case .JogakSuccess(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/success"
//        case .JogakToday:
//            return "/api/modarats/mogaks/jogaks/today"
        case .makePost(let mogakId):
            return "/api/mogaks/\(mogakId)/posts"
        case .detailModalart(modaratId: let modaratId):
            return "/api/modarats/\(modaratId)"
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
        case .getModalartList, .detailModalart, .getJogakList, .getDetailMogakData : return .get
        case .makePost: return .post
        case .JogakSuccess: return .put
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
//        case .JogakToday:
//            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .makePost(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        }
        
        return request
    }
}
