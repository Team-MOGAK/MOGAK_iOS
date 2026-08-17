//
//  ScheduleStartUseCase.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartUseCase {
    func getJogakOccurrences(date: Date) async throws -> [MG2JogakOccurrenceEntity]
    func startJogak(jogakId: Int, scheduledDate: Date) async throws
    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity
    func setJogakCompletion(key: MG2JogakOccurrenceKey, isCompleted: Bool) async throws
}
