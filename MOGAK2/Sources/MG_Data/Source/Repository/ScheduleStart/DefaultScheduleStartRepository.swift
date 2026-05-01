//
//  DefaultScheduleStartRepository.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

final class DefaultScheduleStartRepository: ScheduleStartRepository {
    
    private let networkProvider: NetworkProvider
    
    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
}

extension DefaultScheduleStartRepository {
    
    func getModalartList() async throws -> [ScheduleModalart] {
        let response: ScheduleModalartListResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartList)
        return response.result?.map { $0.toDomain() } ?? []
    }

    func getModalartDetail(modalartId: Int) async throws -> ScheduleModalartDetail? {
        let response: ScheduleModalartDetailResponseDTO = try await networkProvider.request(
            target: MG2ModalartRouter.modalartDetail(modalartId: modalartId)
        )
        return response.result?.toDomain()
    }

    func getMogakPage(modalartId: Int) async throws -> ScheduleMogakPage {
        let response: ScheduleDetailMogakResponseDTO = try await networkProvider.request(
            target: MG2ModalartRouter.modalartMogaks(modalartId: modalartId)
        )
        return response.result?.toDomain() ?? ScheduleMogakPage(mogaks: [], totalCount: 0)
    }
}
