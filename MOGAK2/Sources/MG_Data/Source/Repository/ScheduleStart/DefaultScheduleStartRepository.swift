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

    func getDailyJogaks(date: Date) async throws -> [MG2ScheduleDailyJogakEntity] {
        let response: MG2DailyJogakListResponseDTO = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakDailyCheck(date: MG2APIDateCoding.encode(date))
        )
        return response.result?.dailyJogaks?.map { $0.toDomain() } ?? []
    }

    func addJogakDaily(jogakId: Int) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.addJogakToday(jogakId: jogakId)
        )
    }

    func getDailyJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity? {
        let response: MG2SingleJogakDetailResponseDTO = try await networkProvider.request(
            target: MG2ScheduleStartRouter.dailyJogakDetail(jogakId: jogakId)
        )
        return response.result?.toEntity()
    }

    func markJogakFailed(dailyJogakId: Int) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.jogakFail(dailyJogakId: dailyJogakId)
        )
    }

    func markJogakSucceeded(dailyJogakId: Int) async throws {
        try await networkProvider.requestEmpty(
            target: MG2ScheduleStartRouter.jogakSuccess(dailyJogakId: dailyJogakId)
        )
    }
}
