//
//  ScheduleStartDTO.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

// MARK: - 공통 카테고리 DTO
struct ScheduleCategoryDTO: Decodable {
    let id: Int
    let name: String
    
    func toDomain() -> ScheduleCategory {
        return ScheduleCategory(id: self.id, name: self.name)
    }
}

// MARK: - 1. 모다라트 리스트 조회 DTO
struct ScheduleModalartListResponseDTO: Decodable {
    let time, status, code, message: String?
    let result: [ScheduleModalartDTO]?
}

struct ScheduleModalartDTO: Decodable {
    let id: Int
    let title, color: String
    
    func toDomain() -> ScheduleModalart {
        return ScheduleModalart(id: self.id, title: self.title, color: self.color)
    }
}

// MARK: - 2. 모다라트 디테일 조회 DTO
struct ScheduleModalartDetailResponseDTO: Decodable {
    let time, status, code, message: String?
    let result: ScheduleModalartDetailDTO?
}

struct ScheduleModalartDetailDTO: Decodable {
    let id: Int
    let title, color: String
    let mogakDtoList: [ScheduleMogakSummaryDTO]?
    
    func toDomain() -> ScheduleModalartDetail {
        return ScheduleModalartDetail(
            id: self.id,
            title: self.title,
            color: self.color,
            mogaks: self.mogakDtoList?.map { $0.toDomain() } ?? []
        )
    }
}

struct ScheduleMogakSummaryDTO: Decodable {
    let title: String
    let bigCategory: ScheduleCategoryDTO
    let smallCategory, color: String?
    
    func toDomain() -> ScheduleMogakSummary {
        return ScheduleMogakSummary(
            title: self.title,
            bigCategory: self.bigCategory.toDomain(),
            smallCategory: self.smallCategory,
            color: self.color
        )
    }
}

struct ScheduleDetailMogakResponseDTO: Decodable {
    let time, status, code, message: String?
    let result: ScheduleDetailMogakResultDTO?
}

struct ScheduleDetailMogakResultDTO: Decodable {
    let mogaks: [ScheduleMogakDetailDTO]?
    let size: Int?
}

struct ScheduleMogakDetailDTO: Decodable {
    let id: Int
    let title: String
    let state: String?
    let bigCategory: ScheduleCategoryDTO
    let smallCategory: String?
    let color: String?
    let startAt, endAt: String?
    
    func toDomain() -> ScheduleMogakDetail {
        return ScheduleMogakDetail(
            id: self.id,
            title: self.title,
            state: self.state,
            bigCategory: self.bigCategory.toDomain(),
            smallCategory: self.smallCategory,
            color: self.color,
            startAt: self.startAt,
            endAt: self.endAt
        )
    }
}
