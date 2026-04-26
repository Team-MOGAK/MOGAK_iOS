//
//  DefaultScheduleStartUseCase.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

final class DefaultScheduleStartUseCase: ScheduleStartUseCase {
    
    private let repository: ScheduleStartRepository
    
    init(repository: ScheduleStartRepository) {
        self.repository = repository
    }
}

extension DefaultScheduleStartUseCase {
    
    func getModalartList() async throws -> [ScheduleModalart] {
        let list = try await repository.getModalartList()
        // 비즈니스 로직은 UseCase에 위치시키고, ViewModel은 표시 상태만 관리한다.
        return list
    }

    func getModalartDetail(modalartId: Int) async throws -> ScheduleModalartDetail? {
        try await repository.getModalartDetail(modalartId: modalartId)
    }

    func getMogakPage(modalartId: Int) async throws -> ScheduleMogakPage {
        try await repository.getMogakPage(modalartId: modalartId)
    }
}
