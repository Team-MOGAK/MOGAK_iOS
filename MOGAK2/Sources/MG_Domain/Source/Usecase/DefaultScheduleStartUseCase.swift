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

    func getMogakDetailJogaks(mogakId: Int, dailyDate: String) async throws -> [ScheduleJogakDetail]? {
        try await repository.getMogakDetailJogaks(mogakId: mogakId, dailyDate: dailyDate)
    }

    func getCheckDailyJogak(dailyDate: String) async throws -> [JogakDailyCheck]? {
        try await repository.getCheckDailyJogak(dailyDate: dailyDate)
    }

    func addJogakDaily(jogakId: Int) async throws -> [JogakDailyStartResponse]? {
        try await repository.addJogakDaily(jogakId: jogakId)
    }

    func getDailyJogakDetail(jogakId: Int) async throws -> DailyJogakDetail? {
        try await repository.getDailyJogakDetail(jogakId: jogakId)
    }

    func jogakFail(dailyJogakId: Int) async throws -> [JogakFail]? {
        try await repository.jogakFail(dailyJogakId: dailyJogakId)
    }

    func jogakSuccess(dailyJogakId: Int) async throws -> [JogakSuccess]? {
        try await repository.jogakSuccess(dailyJogakId: dailyJogakId)
    }

    func getJogakMonth(startDay: String, endDay: String) async throws -> [JogakMonth] {
        try await repository.getJogakMonth(startDay: startDay, endDay: endDay)
    }
}
