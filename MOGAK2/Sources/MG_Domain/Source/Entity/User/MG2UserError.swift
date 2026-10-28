import Foundation

enum MG2UserError: LocalizedError {
    case nicknameTaken

    var errorDescription: String? {
        switch self {
        case .nicknameTaken:
            return "이미 사용 중인 닉네임이에요"
        }
    }
}
