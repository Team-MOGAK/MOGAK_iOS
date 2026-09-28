import Foundation

private enum MG2NicknameError: LocalizedError {
    case invalidNickname(String)

    var errorDescription: String? {
        switch self {
        case .invalidNickname(let message):
            return message
        }
    }
}

@MainActor
final class MG2NicknameViewModel {
    private static let nicknameLengthRange = 2...10

    let profileImageIDs = MG2ProfileImage.ids

    private let userUseCase: UserUseCase
    private let userState: MG2UserState
    private let mode: MG2ProfileSetupMode
    private(set) var selectedProfileImageID: Int?

    init(userUseCase: UserUseCase, userState: MG2UserState, mode: MG2ProfileSetupMode) {
        self.userUseCase = userUseCase
        self.userState = userState
        self.mode = mode
        switch mode {
        case .registration(let draft):
            selectedProfileImageID = draft.profileImageID
        case .editing:
            selectedProfileImageID = userState.profileImageID
        }
    }

    var isEditing: Bool {
        if case .editing = mode { return true }
        return false
    }

    var currentNickname: String { userState.nickname }
    var nicknameMaximumLength: Int { Self.nicknameLengthRange.upperBound }

    var selectedProfileImageIndex: Int? {
        selectedProfileImageID.flatMap(profileImageIDs.firstIndex(of:))
    }

    private var hasProfileImageChange: Bool {
        selectedProfileImageID != nil && selectedProfileImageID != userState.profileImageID
    }

    func selectProfileImage(at index: Int) {
        guard profileImageIDs.indices.contains(index) else { return }
        selectedProfileImageID = profileImageIDs[index]
    }

    func nicknameValidationMessage(_ nickname: String) -> String? {
        guard nickname.count >= Self.nicknameLengthRange.lowerBound else { return "2글자 이상 입력해주세요" }
        guard nickname.count <= Self.nicknameLengthRange.upperBound else { return "10글자 이하로 입력해주세요" }
        return nil
    }

    func canSubmit(_ nickname: String) -> Bool {
        switch mode {
        case .registration:
            return nicknameValidationMessage(nickname) == nil
        case .editing:
            let hasNicknameChange = !nickname.isEmpty && nickname != userState.nickname && nicknameValidationMessage(nickname) == nil
            return hasNicknameChange || hasProfileImageChange
        }
    }

    func submit(_ nickname: String, completion: @escaping (Result<MG2ProfileSetupResult, Error>) -> Void) {
        switch mode {
        case .registration(var draft):
            if let message = nicknameValidationMessage(nickname) {
                completion(.failure(MG2NicknameError.invalidNickname(message)))
                return
            }
            Task {
                do {
                    try await userUseCase.verifyNickname(nickname)
                    draft.nickname = nickname
                    draft.profileImageID = selectedProfileImageID
                    completion(.success(.continueRegistration(draft)))
                } catch {
                    completion(.failure(error))
                }
            }
        case .editing:
            let nicknameToUpdate = nickname.isEmpty || nickname == userState.nickname ? nil : nickname
            if let nicknameToUpdate, let message = nicknameValidationMessage(nicknameToUpdate) {
                completion(.failure(MG2NicknameError.invalidNickname(message)))
                return
            }
            let profileImageToUpdate = hasProfileImageChange ? selectedProfileImageID : nil
            Task {
                do {
                    if let nicknameToUpdate {
                        try await userUseCase.changeNickname(nicknameToUpdate)
                    }
                    if let profileImageToUpdate {
                        try await userUseCase.changeProfileImage(profileImageToUpdate)
                    }
                    completion(.success(.profileUpdated))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
