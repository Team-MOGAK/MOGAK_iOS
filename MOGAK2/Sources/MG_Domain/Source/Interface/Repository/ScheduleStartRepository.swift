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
}
