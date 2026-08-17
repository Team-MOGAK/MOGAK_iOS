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

    func getJogakOccurrences(date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        try await repository.getJogakOccurrences(date: date)
    }

    func startJogak(jogakId: Int, scheduledDate: Date) async throws {
        try await repository.startJogak(jogakId: jogakId, scheduledDate: scheduledDate)
    }

    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity {
        try await repository.getJogakDetail(jogakId: jogakId)
    }

    func setJogakCompletion(key: MG2JogakOccurrenceKey, isCompleted: Bool) async throws {
        if isCompleted {
            try await repository.markJogakSucceeded(key: key)
        } else {
            try await repository.markJogakFailed(key: key)
        }
    }
}
