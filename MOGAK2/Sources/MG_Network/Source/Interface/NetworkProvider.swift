import Foundation

protocol NetworkRequest {
    var requiresAuthorization: Bool { get }
    func makeURLRequest() throws -> URLRequest
}

struct NetworkMultipartPart {
    let data: Data
    let name: String
    let fileName: String?
    let mimeType: String?

    init(
        data: Data,
        name: String,
        fileName: String? = nil,
        mimeType: String? = nil
    ) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

protocol NetworkProvider {
    func request<T: Decodable>(target: NetworkRequest) async throws -> T
    func requestEmpty(target: NetworkRequest) async throws
    func upload<T: Decodable>(target: NetworkRequest, parts: [NetworkMultipartPart]) async throws -> T
    func uploadEmpty(target: NetworkRequest, parts: [NetworkMultipartPart]) async throws
}
