//
//  ScheduleStartUseCase.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

protocol ScheduleStartUseCase {
    func getModalartList() async throws -> [ScheduleModalart]
}
