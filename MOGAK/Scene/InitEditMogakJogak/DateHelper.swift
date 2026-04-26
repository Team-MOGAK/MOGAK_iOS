//
//  DateHelper.swift
//  MOGAK
//
//  Created by 이재혁 on 12/12/23.
//

import Foundation

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

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

#endif
