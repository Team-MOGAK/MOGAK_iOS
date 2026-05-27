//
//  ScheduleStartRepository.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartRepository {
    func getModalartList() async throws -> [ScheduleModalart]
    func getModalartDetail(modalartId: Int) async throws -> ScheduleModalartDetail?
    func getMogakPage(modalartId: Int) async throws -> ScheduleMogakPage
    func getMogakDetailJogaks(mogakId: Int, dailyDate: String) async throws -> [ScheduleJogakDetail]?
    func getCheckDailyJogak(dailyDate: String) async throws -> [JogakDailyCheck]?
    func addJogakDaily(jogakId: Int) async throws -> [JogakDailyStartResponse]?
    func getDailyJogakDetail(jogakId: Int) async throws -> DailyJogakDetail?
    func jogakFail(dailyJogakId: Int) async throws -> [JogakFail]?
    func jogakSuccess(dailyJogakId: Int) async throws -> [JogakSuccess]?
    func getJogakMonth(startDay: String, endDay: String) async throws -> [JogakMonth]
}
