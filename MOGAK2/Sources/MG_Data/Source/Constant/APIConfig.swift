import Foundation

enum APIConfig {
    /// Configuration/BASE_URL.xcconfig → Info.plist BASE_URL
    static let baseURL: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String, !value.isEmpty else {
            assertionFailure("[APIConfig] Missing Info.plist key: BASE_URL")
            return ""
        }
        return value
    }()
}
