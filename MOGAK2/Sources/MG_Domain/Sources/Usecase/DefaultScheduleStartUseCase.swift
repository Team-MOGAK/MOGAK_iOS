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
        ///
        ///이곳에서 비즈니스 로직을 갖고 놉니다.
        ///ViewModel에서는 데이터를 갖고 view에 위치할 곳만 잡습니다.
        ///
        return list
    }
    
}
