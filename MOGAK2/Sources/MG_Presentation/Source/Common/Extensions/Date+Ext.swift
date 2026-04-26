//
//  Date+Ext.swift
//  MOGAK
//
//  Created by 김라영 on 2024/02/14.
//

import Foundation

extension Date {
    //MARK: - 조각 조회할 때 오늘날짜를 넣어줘야 해서 date타입을 string으로 형변환
    func jogakTodayDateToString() -> String {
        let date: Date = self

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.string(from: date)
    }
}
