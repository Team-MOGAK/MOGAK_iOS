import Foundation

final class MG2AdPolicyStore: AdPolicyStorage {
    private enum Key {
        static let installDate = "MG2AdInstallDate"
        static let interstitialDates = "MG2AdInterstitialDates"
        static let lastAppOpenAdDate = "MG2AdLastAppOpenDate"
        static let lastBackgroundDate = "MG2AdLastBackgroundDate"
        static let unlockedPastDays = "MG2AdUnlockedPastDays"
    }

    private let defaults = UserDefaults.standard

    var installDate: Date? {
        get { defaults.object(forKey: Key.installDate) as? Date }
        set { defaults.set(newValue, forKey: Key.installDate) }
    }

    var interstitialDates: [Date] {
        get { defaults.array(forKey: Key.interstitialDates) as? [Date] ?? [] }
        set { defaults.set(newValue, forKey: Key.interstitialDates) }
    }

    var lastAppOpenAdDate: Date? {
        get { defaults.object(forKey: Key.lastAppOpenAdDate) as? Date }
        set { defaults.set(newValue, forKey: Key.lastAppOpenAdDate) }
    }

    var lastBackgroundDate: Date? {
        get { defaults.object(forKey: Key.lastBackgroundDate) as? Date }
        set { defaults.set(newValue, forKey: Key.lastBackgroundDate) }
    }

    var unlockedPastDays: [Date] {
        get { defaults.array(forKey: Key.unlockedPastDays) as? [Date] ?? [] }
        set { defaults.set(newValue, forKey: Key.unlockedPastDays) }
    }
}
