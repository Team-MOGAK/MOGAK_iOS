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

    // TODO(server): 모다라트 디자인 시스템에 필요한 API. 서버 지원 확인 후 추가.
    // - 이번 주 진척률 (판 칸 채움 · 가운데 목표 % 캡슐)
    // - 지난 날 기록 열기 (어제 무료 · 7일 안 보상형 광고). getJogakOccurrences(date:)로 충분한지 확인 필요
    // - 조각 타이머 (모각이 hurry 포즈)
}

extension ScheduleStartRepository {
    /// 루틴 조각의 반복 요일. 조각마다 상세 API를 불러야 해서 하나씩 요청한다.
    func routineWeekdays(for occurrences: [MG2JogakOccurrenceEntity]) async throws -> [Int: [MG2Weekday]] {
        var weekdaysByJogakID = [Int: [MG2Weekday]]()
        for occurrence in occurrences where occurrence.isRoutine {
            let jogakID = occurrence.key.jogakID
            weekdaysByJogakID[jogakID] = try await getJogakDetail(jogakId: jogakID).days
        }
        return weekdaysByJogakID
    }
}
