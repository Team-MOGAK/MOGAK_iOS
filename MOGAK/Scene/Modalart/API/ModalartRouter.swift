//
//  ModalartRouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/24.
//

import Foundation
import Alamofire

let accesstoken = "Bearer" + " eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJ1c2VyUGsiOiIxIiwiaWF0IjoxNjkyNzIyNDEwLCJleHAiOjE3MjQyNTg0MTB9.sqb4ioXK5fTGz7CRzL1ZBZ9yxDvBwIUfY-Azbo3aVuM"

enum ModalartRouter: URLRequestConvertible {
    
    case getModalartList
    case detailModalart(modaratId: Int)
    case getDetailMogakData(modaratId: Int)
    case delteModalart(modaratId: Int)
    case createModalrt(data: ModalartMainData)
    case editModalart(data: ModalartMainData)
    
    var endPoint: String {
        switch self {
        case .getModalartList: return "api/modarats"
        case .detailModalart(let modaratId): return "api/modarats/\(modaratId)"
        case .getDetailMogakData(let modaratId):
            return "api/modarats/\(modaratId)/mogaks"
        case .delteModalart(let modaratId): return "api/modarats/\(modaratId)"
        case .createModalrt: return "api/modarats"
        case .editModalart(let data): return "api/modarats/\(data.id)"
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        switch self {
        default: return HTTPHeaders(["accept":"application/json", "Authorization" : accesstoken])
//        default: return HTTPHeaders(["accept":"application/json"])
        }
    }
    
    //어떤 방식(get, post, delete, update)
    var method: HTTPMethod {
        switch self {
        case .getModalartList, .detailModalart, .getDetailMogakData: return .get
        case .delteModalart: return .delete
        case .createModalrt: return .post
        case .editModalart: return .put
        }
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = BASE_URL.appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: url)!
        
        var request = URLRequest(url: urlString)
        request.method = method
        request.headers = headers
        
        switch self {
        case .getModalartList:
            request = try URLEncoding.queryString.encode(request, with: parameters) //body가 필요없을떄
        case .detailModalart:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getDetailMogakData:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .delteModalart:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .createModalrt(let data):
            request = try JSONParameterEncoder().encode(data, into: request) //body가 필요할때
        case .editModalart(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        }

        return request
    }
}
