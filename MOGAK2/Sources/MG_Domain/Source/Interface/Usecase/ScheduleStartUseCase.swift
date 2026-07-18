//
//  ScheduleStartUseCase.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartUseCase {
    func getDailyJogaks(date: Date) async throws -> [MG2ScheduleDailyJogakEntity]
    func addJogakDaily(jogakId: Int) async throws
    func getDailyJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity?
    func setJogakAchievement(dailyJogakId: Int, isAchievement: Bool) async throws
}
