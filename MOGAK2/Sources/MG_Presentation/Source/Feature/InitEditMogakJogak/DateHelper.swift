//
//  DateHelper.swift
//  MOGAK
//
//  Created by 이재혁 on 12/12/23.
//

import Foundation

class DateHelper {

    static let shared = DateHelper()

    lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .iso8601)
        cal.locale = Locale.current
        cal.timeZone = TimeZone.current
        return cal
    }()
}

extension Date {

    func isEqual(date: Date = Date(), toGranularity: Calendar.Component = .day) -> Bool {
        let calendar = DateHelper.shared.calendar
        let ordered = calendar.compare(date, to: self, toGranularity: toGranularity)
        return ordered == .orderedSame
    }
}
