//
//  ScheduleStartEntity.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

// MARK: - 공통 카테고리
struct ScheduleCategory {
    let id: Int
    let name: String
}

// MARK: - 모다라트 기본 정보 (리스트 등에 사용)
struct ScheduleModalart {
    let id: Int
    let title: String
    let color: String
}

// MARK: - 모다라트 디테일 (모다라트 + 하위 모각 리스트)
struct ScheduleModalartDetail {
    let id: Int
    let title: String
    let color: String
    let mogaks: [ScheduleMogakSummary]
}

// MARK: - 모각 기본 정보
struct ScheduleMogakSummary {
    let title: String
    let bigCategory: ScheduleCategory
    let smallCategory: String?
    let color: String?
}

// MARK: - 모각 상세 정보 (날짜, 상태 포함)
struct ScheduleMogakDetail {
    let id: Int
    let title: String
    let state: String?
    let bigCategory: ScheduleCategory
    let smallCategory: String?
    let color: String?
    let startAt: String?
    let endAt: String?
}

// MARK: - 모각 상세 목록 페이지
struct ScheduleMogakPage {
    let mogaks: [ScheduleMogakDetail]
    let totalCount: Int
}
