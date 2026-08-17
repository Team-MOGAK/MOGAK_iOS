//
//  ScheduleStartRepository.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartRepository {
    func getJogakOccurrences(date: Date) async throws -> [MG2JogakOccurrenceEntity]
    func startJogak(jogakId: Int, scheduledDate: Date) async throws
    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity
    func markJogakFailed(key: MG2JogakOccurrenceKey) async throws
    func markJogakSucceeded(key: MG2JogakOccurrenceKey) async throws
}
