//
//  ScheduleStartRepository.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartRepository {
    func getDailyJogaks(date: Date) async throws -> [MG2ScheduleDailyJogakEntity]
    func addJogakDaily(jogakId: Int) async throws
    func getDailyJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity?
    func markJogakFailed(dailyJogakId: Int) async throws
    func markJogakSucceeded(dailyJogakId: Int) async throws
}
