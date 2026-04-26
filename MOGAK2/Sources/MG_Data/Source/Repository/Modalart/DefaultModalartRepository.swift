import Foundation
import Alamofire

final class DefaultModalartRepository: ModalartRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getModalartList() async throws -> [MG2ModalartListItemEntity] {
        let response: MG2ModalartListResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartList)
        return (response.result ?? []).map { $0.toEntity() }
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        let response: MG2ModalartDetailResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartDetail(modalartId: modalartId))
        return response.result?.toEntity()
    }

    func getModalartMogakPage(modalartId: Int) async throws -> MG2ModalartMogakPageEntity? {
        let response: MG2ModalartMogakPageResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartMogaks(modalartId: modalartId))
        return response.result?.toEntity()
    }

    func getMogakDetailJogaks(mogakId: Int, date: String) async throws -> [JogakDetail] {
        let response: JogakDetailResponse = try await networkProvider.request(target: MG2ModalartRouter.mogakDetailJogaks(mogakId: mogakId, date: date))
        return response.result ?? []
    }

    func createModalart(title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ModalartUpsertResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartCreate(title: title, color: color))
        return response.result.toEntity()
    }

    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        let response: MG2ModalartUpsertResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartEdit(id: id, title: title, color: color))
        return response.result.toEntity()
    }

    func deleteModalart(id: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(MG2ModalartRouter.modalartDelete(id: id))
                .validate()
                .responseData(emptyResponseCodes: [200, 204, 205]) { response in
                    switch response.result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func deleteMogak(mogakId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(MG2ModalartRouter.mogakDelete(id: mogakId))
                .validate()
                .responseData(emptyResponseCodes: [200, 204, 205]) { response in
                    switch response.result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func deleteJogak(jogakId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(MG2ModalartRouter.jogakDelete(id: jogakId))
                .validate()
                .responseData(emptyResponseCodes: [200, 204, 205]) { response in
                    switch response.result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
