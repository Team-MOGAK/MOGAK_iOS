import Foundation

enum MG2APIDateCoding {
    static func encode(_ date: Date) -> String {
        makeFormatter().string(from: date)
    }

    static func decode(_ value: String?) -> Date? {
        guard let value else { return nil }
        return makeFormatter().date(from: value)
    }

    private static func makeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

enum MG2APIWeekdayCoding {
    static func encode(_ weekdays: [MG2Weekday]) -> [String] {
        weekdays.map { weekday in
            switch weekday {
            case .monday: "MONDAY"
            case .tuesday: "TUESDAY"
            case .wednesday: "WEDNESDAY"
            case .thursday: "THURSDAY"
            case .friday: "FRIDAY"
            case .saturday: "SATURDAY"
            case .sunday: "SUNDAY"
            }
        }
    }

    static func decode(_ values: [String]?) -> [MG2Weekday] {
        (values ?? []).compactMap { value in
            switch value {
            case "MONDAY": .monday
            case "TUESDAY": .tuesday
            case "WEDNESDAY": .wednesday
            case "THURSDAY": .thursday
            case "FRIDAY": .friday
            case "SATURDAY": .saturday
            case "SUNDAY": .sunday
            default: nil
            }
        }
    }
}
