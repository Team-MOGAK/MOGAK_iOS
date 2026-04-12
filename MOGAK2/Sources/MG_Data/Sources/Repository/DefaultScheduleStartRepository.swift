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
        let DTO: ScheduleModalartListResponseDTO = try await networkProvider.request(target: ScheduleStartRouter.getModalartList )
        
        return DTO.result?.map { $0.toDomain() } ?? []
    }
}
