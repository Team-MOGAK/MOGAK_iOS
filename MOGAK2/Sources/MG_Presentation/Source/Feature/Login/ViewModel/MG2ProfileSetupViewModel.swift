import Foundation

struct MG2JobSection {
    let title: String
    let jobs: [String]
}

enum MG2ProfileSetupMode {
    case registration
    case editing
}

enum MG2NicknameSubmissionResult {
    case registrationVerified
    case profileUpdated
}

enum MG2JobSubmissionResult {
    case selectedForRegistration
    case profileUpdated
}

enum MG2AgreementItem {
    case age
    case service
    case privacy
    case marketing
}

struct MG2AgreementState {
    var age = false
    var service = false
    var privacy = false
    var marketing = false

    var hasAcceptedRequiredTerms: Bool {
        age && service && privacy
    }

    var hasAcceptedAllTerms: Bool {
        age && service && privacy && marketing
    }
}

struct MG2ProfileSetupViewState {
    var agreements = MG2AgreementState()
    var jobSections = [MG2JobSection]()
    var selectedJob = ""
    var selectedRegion = ""
    var pendingProfileImageData: Data?
    var hasProfileImageChange = false
}

private enum MG2ProfileSetupError: LocalizedError {
    case invalidNickname(String)

    var errorDescription: String? {
        switch self {
        case .invalidNickname(let message):
            return message
        }
    }
}

@MainActor
final class MG2ProfileSetupViewModel {
    private static let nicknameLengthRange = 2...10

    private static let jobs = [
        "기획/전략", "법무,사무,총무", "인사/HR", "회계/세무", "마케팅/광고/MD",
        "개발/데이터", "디자인", "물류/무역", "운전/운송/배송", "영업", "고객상담/TM",
        "금융/보험", "식/음료", "고객서비스/리테일", "엔지니어링/설계", "제조/생산",
        "교육", "건축/시설", "의료/바이오", "미디어/문화", "스포츠", "공공복지",
        "자영업", "군인", "의료", "회계사", "법무사", "노무사", "세무사", "관세사",
        "교사", "디지털노마드", "영상제작자", "크리에이터"
    ]

    private static let koreanInitials = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]

    private static let regions = [
        "서울특별시", "경기도", "세종특별자치시", "대전광역시", "광주광역시",
        "대구광역시", "부산광역시", "울산광역시", "경상남도", "경상북도",
        "전라남도", "전라북도", "충청남도", "충청북도", "강원도", "제주도",
        "독도/울릉도"
    ]

    private let userUseCase: UserUseCase
    private let userState: MG2UserState
    private let sessionStore: MG2SessionStoring
    private(set) var state = MG2ProfileSetupViewState()

    init(
        userUseCase: UserUseCase,
        userState: MG2UserState,
        sessionStore: MG2SessionStoring
    ) {
        self.userUseCase = userUseCase
        self.userState = userState
        self.sessionStore = sessionStore
    }

    var nickname: String { userState.nickname }
    var nicknameMaximumLength: Int { Self.nicknameLengthRange.upperBound }
    var availableRegions: [String] { Self.regions }
    var profileImageData: Data? {
        state.hasProfileImageChange
            ? state.pendingProfileImageData
            : userState.profileImageData
    }

    func resetAgreements() {
        state.agreements = MG2AgreementState()
    }

    func toggleAllAgreements() {
        let newValue = !state.agreements.hasAcceptedAllTerms
        state.agreements = MG2AgreementState(
            age: newValue,
            service: newValue,
            privacy: newValue,
            marketing: newValue
        )
    }

    func toggleAgreement(_ item: MG2AgreementItem) {
        switch item {
        case .age:
            state.agreements.age.toggle()
        case .service:
            state.agreements.service.toggle()
        case .privacy:
            state.agreements.privacy.toggle()
        case .marketing:
            state.agreements.marketing.toggle()
        }
    }

    func beginNicknameSetup() {
        state.pendingProfileImageData = nil
        state.hasProfileImageChange = false
    }

    func updateProfileImageData(_ imageData: Data?, mode: MG2ProfileSetupMode) {
        switch mode {
        case .registration:
            userState.profileImageData = imageData
        case .editing:
            state.pendingProfileImageData = imageData
            state.hasProfileImageChange = true
        }
    }

    func beginJobSelection() {
        state.selectedJob = ""
        updateJobSections(matching: "")
    }

    func updateJobSections(matching query: String) {
        state.jobSections = makeJobSections(matching: query)
    }

    func selectJob(section: Int, row: Int) {
        guard state.jobSections.indices.contains(section),
              state.jobSections[section].jobs.indices.contains(row) else { return }
        let job = state.jobSections[section].jobs[row]
        state.selectedJob = state.selectedJob == job ? "" : job
    }

    func beginRegionSelection() {
        state.selectedRegion = ""
    }

    func selectRegion(at index: Int) {
        guard Self.regions.indices.contains(index) else { return }
        state.selectedRegion = Self.regions[index]
    }

    func nicknameValidationMessage(_ nickname: String) -> String? {
        guard nickname.count >= Self.nicknameLengthRange.lowerBound else {
            return "2글자 이상 입력해주세요"
        }
        guard nickname.count <= Self.nicknameLengthRange.upperBound else {
            return "10글자 이하로 입력해주세요"
        }
        return nil
    }

    func canSubmitNickname(_ nickname: String, mode: MG2ProfileSetupMode) -> Bool {
        switch mode {
        case .registration:
            return nicknameValidationMessage(nickname) == nil
        case .editing:
            let hasNicknameChange = !nickname.isEmpty
                && nickname != userState.nickname
                && nicknameValidationMessage(nickname) == nil
            return hasNicknameChange || state.hasProfileImageChange
        }
    }

    private func makeJobSections(matching query: String) -> [MG2JobSection] {
        let jobs = query.isEmpty
            ? Self.jobs
            : Self.jobs.filter { $0.range(of: query, options: .caseInsensitive) != nil }

        let grouped = Dictionary(grouping: jobs, by: Self.sectionTitle)
        return grouped.keys.sorted().map {
            MG2JobSection(title: $0, jobs: grouped[$0] ?? [])
        }
    }

    private static func sectionTitle(for job: String) -> String {
        guard let scalar = job.unicodeScalars.first else { return "" }
        let value = scalar.value
        guard (0xAC00...0xD7A3).contains(value) else {
            return job.prefix(1).uppercased()
        }

        let index = Int((value - 0xAC00) / (21 * 28))
        return koreanInitials[index]
    }

    func submitNickname(
        _ nickname: String,
        mode: MG2ProfileSetupMode,
        completion: @escaping (Result<MG2NicknameSubmissionResult, Error>) -> Void
    ) {
        let nicknameToUpdate: String?
        switch mode {
        case .registration:
            if let message = nicknameValidationMessage(nickname) {
                completion(.failure(MG2ProfileSetupError.invalidNickname(message)))
                return
            }
            nicknameToUpdate = nickname
        case .editing:
            nicknameToUpdate = nickname.isEmpty || nickname == userState.nickname ? nil : nickname
            if let nicknameToUpdate,
               let message = nicknameValidationMessage(nicknameToUpdate) {
                completion(.failure(MG2ProfileSetupError.invalidNickname(message)))
                return
            }
        }

        Task {
            do {
                switch mode {
                case .registration:
                    try await userUseCase.verifyNickname(nickname)
                    userState.nickname = nickname
                    completion(.success(.registrationVerified))
                case .editing:
                    if let nicknameToUpdate {
                        try await userUseCase.changeNickname(nicknameToUpdate)
                        userState.nickname = nicknameToUpdate
                    }
                    if state.hasProfileImageChange,
                       let changedProfileImageData = state.pendingProfileImageData {
                        try await userUseCase.userImageChange(
                            imageData: changedProfileImageData,
                            userNickname: userState.nickname
                        )
                        userState.profileImageData = changedProfileImageData
                    }
                    completion(.success(.profileUpdated))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    func submitSelectedJob(
        mode: MG2ProfileSetupMode,
        completion: @escaping (Result<MG2JobSubmissionResult, Error>) -> Void
    ) {
        let job = state.selectedJob
        guard !job.isEmpty else { return }
        switch mode {
        case .registration:
            userState.job = job
            completion(.success(.selectedForRegistration))
        case .editing:
            Task {
                do {
                    try await userUseCase.changeJob(job)
                    userState.job = job
                    completion(.success(.profileUpdated))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func joinUser(completion: @escaping (Result<Void, Error>) -> Void) {
        let region = state.selectedRegion
        guard !region.isEmpty else { return }
        userState.region = region
        let registration = MG2UserRegistration(
            nickname: userState.nickname,
            job: userState.job,
            address: userState.region
        )
        Task {
            do {
                let result = try await userUseCase.userJoin(
                    registration: registration,
                    profileImageData: userState.profileImageData
                )
                sessionStore.saveSession(
                    accessToken: result.tokens.accessToken,
                    refreshToken: result.tokens.refreshToken,
                    userID: result.userId,
                    isRegistered: true
                )
                userState.nickname = result.nickname
                sessionStore.setFirstTime(false)
                userState.isRegistered = true
                userState.loginState = .login
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
