import Foundation

protocol NetworkRequest {
    var requiresAuthorization: Bool { get }
    func makeURLRequest() throws -> URLRequest
}

protocol NetworkProvider {
    func request<T: Decodable>(target: NetworkRequest) async throws -> T
    func requestEmpty(target: NetworkRequest) async throws
}
