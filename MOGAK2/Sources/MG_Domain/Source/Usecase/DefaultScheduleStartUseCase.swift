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

    func getDailyJogaks(date: Date) async throws -> [MG2ScheduleDailyJogakEntity] {
        try await repository.getDailyJogaks(date: date)
    }

    func addJogakDaily(jogakId: Int) async throws {
        try await repository.addJogakDaily(jogakId: jogakId)
    }

    func getDailyJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity? {
        try await repository.getDailyJogakDetail(jogakId: jogakId)
    }

    func setJogakAchievement(dailyJogakId: Int, isAchievement: Bool) async throws {
        if isAchievement {
            try await repository.markJogakSucceeded(dailyJogakId: dailyJogakId)
        } else {
            try await repository.markJogakFailed(dailyJogakId: dailyJogakId)
        }
    }
}
