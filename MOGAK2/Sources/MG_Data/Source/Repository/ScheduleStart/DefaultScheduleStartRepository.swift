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
    
    func getModalartList() async throws -> [ScheduleModalart] {
        let response: ScheduleModalartListResponseDTO = try await networkProvider.request(target: MG2ModalartRouter.modalartList)
        return response.result?.map { $0.toDomain() } ?? []
    }

    func getModalartDetail(modalartId: Int) async throws -> ScheduleModalartDetail? {
        let response: ScheduleModalartDetailResponseDTO = try await networkProvider.request(
            target: MG2ModalartRouter.modalartDetail(modalartId: modalartId)
        )
        return response.result?.toDomain()
    }

    func getMogakPage(modalartId: Int) async throws -> ScheduleMogakPage {
        let response: ScheduleDetailMogakResponseDTO = try await networkProvider.request(
            target: MG2ModalartRouter.modalartMogaks(modalartId: modalartId)
        )
        return response.result?.toDomain() ?? ScheduleMogakPage(mogaks: [], totalCount: 0)
    }

    func getMogakDetailJogaks(mogakId: Int, dailyDate: String) async throws -> [ScheduleJogakDetail]? {
        let response: ScheduleJogakDetailResponse = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakList(mogakId: mogakId, date: dailyDate)
        )
        return response.result
    }

    func getCheckDailyJogak(dailyDate: String) async throws -> [JogakDailyCheck]? {
        let response: JogakDailyCheck = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakDailyCheck(date: dailyDate)
        )
        return [response]
    }

    func addJogakDaily(jogakId: Int) async throws -> [JogakDailyStartResponse]? {
        let response: JogakDailyStartResponse = try await networkProvider.request(
            target: MG2ScheduleStartRouter.addJogakToday(jogakId: jogakId)
        )
        return [response]
    }

    func getDailyJogakDetail(jogakId: Int) async throws -> DailyJogakDetail? {
        try await networkProvider.request(
            target: MG2ScheduleStartRouter.dailyJogakDetail(jogakId: jogakId)
        )
    }

    func jogakFail(dailyJogakId: Int) async throws -> [JogakFail]? {
        let response: JogakFail = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakFail(dailyJogakId: dailyJogakId)
        )
        return [response]
    }

    func jogakSuccess(dailyJogakId: Int) async throws -> [JogakSuccess]? {
        let response: JogakSuccess = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakSuccess(dailyJogakId: dailyJogakId)
        )
        return [response]
    }

    func getJogakMonth(startDay: String, endDay: String) async throws -> [JogakMonth] {
        let response: JogakMonth = try await networkProvider.request(
            target: MG2ScheduleStartRouter.jogakMonth(startDay: startDay, endDay: endDay)
        )
        return [response]
    }
}
