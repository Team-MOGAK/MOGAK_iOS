//
//  DefaultScheduleStartRepository.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

final class DefaultScheduleStartRepository: ScheduleStartRepository {
    
    private let networkProvider: NetworkProvider
    
    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
}

extension DefaultScheduleStartRepository {

    func getJogakOccurrences(date: Date) async throws -> [MG2JogakOccurrenceEntity] {
        let response: MG2JogakOccurrencePageResponseDTO = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakOccurrences(date: MG2APIDateCoding.encode(date))
        )
        return response.result.jogaks.map { $0.toDomain() }
    }

    func startJogak(jogakId: Int, scheduledDate: Date) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.startJogak(
                jogakId: jogakId,
                scheduledDate: MG2APIDateCoding.encode(scheduledDate)
            )
        )
    }

    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity {
        let response: MG2SingleJogakDetailResponseDTO = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakDetail(jogakId: jogakId)
        )
        return response.result.toEntity()
    }

    func markJogakFailed(key: MG2JogakOccurrenceKey) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.failJogak(
                jogakId: key.jogakID,
                scheduledDate: key.scheduledDate
            )
        )
    }

    func markJogakSucceeded(key: MG2JogakOccurrenceKey) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.succeedJogak(
                jogakId: key.jogakID,
                scheduledDate: key.scheduledDate
            )
        )
    }
}
