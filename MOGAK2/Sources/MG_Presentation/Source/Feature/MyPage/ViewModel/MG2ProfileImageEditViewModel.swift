import Foundation

@MainActor
final class MG2ProfileImageEditViewModel {
    let profileImageIDs = MG2ProfileImage.ids

    private let userUseCase: UserUseCase
    private let userState: MG2UserState
    private(set) var selectedImageID: Int?

    init(userUseCase: UserUseCase, userState: MG2UserState) {
        self.userUseCase = userUseCase
        self.userState = userState
        selectedImageID = userState.profileImageID
    }

    var selectedIndex: Int? { selectedImageID.flatMap(profileImageIDs.firstIndex(of:)) }

    /// 고른 이미지가 없으면 기본 이미지를 보여준다.
    var selectedImageName: String { MG2ProfileImage.assetName(for: selectedImageID) }

    /// 지금 이미지와 다른 이미지를 골랐을 때만 저장할 수 있다.
    var canSubmit: Bool { selectedImageID != nil && selectedImageID != userState.profileImageID }

    func selectImage(at index: Int) {
        guard profileImageIDs.indices.contains(index) else { return }
        selectedImageID = profileImageIDs[index]
    }

    func submit(completion: @escaping (Result<Void, Error>) -> Void) {
        guard canSubmit, let selectedImageID else { return }
        Task {
            do {
                try await userUseCase.changeProfileImage(selectedImageID)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
