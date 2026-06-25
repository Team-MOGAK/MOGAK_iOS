import Foundation

enum MG2LaunchStorage {
    private enum Key {
        static let isFirstTime = "isFirstTime"
        static let userIsRegistered = "MG2UserIsRegistered"
    }

    static var isFirstTime: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: Key.isFirstTime) != nil else {
            defaults.set(true, forKey: Key.isFirstTime)
            return true
        }
        return defaults.bool(forKey: Key.isFirstTime)
    }

    static var storedUserIsRegistered: Bool? {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: Key.userIsRegistered) != nil else { return nil }
        return defaults.bool(forKey: Key.userIsRegistered)
    }

    static func setFirstTime(_ isFirstTime: Bool) {
        UserDefaults.standard.set(isFirstTime, forKey: Key.isFirstTime)
    }

    static func setUserIsRegistered(_ isRegistered: Bool) {
        UserDefaults.standard.set(isRegistered, forKey: Key.userIsRegistered)
    }

    static func clearUserRegistration() {
        UserDefaults.standard.removeObject(forKey: Key.userIsRegistered)
    }
}
