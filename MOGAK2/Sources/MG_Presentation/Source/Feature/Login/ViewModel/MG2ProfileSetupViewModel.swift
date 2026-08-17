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

struct MG2AgreementSelection {
    let item: MG2ConsentItemEntity
    var agreed = false
}

struct MG2AgreementState {
    var selections = [MG2AgreementSelection]()
    var hasLoaded = false

    var hasAcceptedRequiredTerms: Bool {
        hasLoaded && selections.allSatisfy { !$0.item.required || $0.agreed }
    }

    var hasAcceptedAllTerms: Bool {
        hasLoaded && !selections.isEmpty && selections.allSatisfy(\.agreed)
    }
}

struct MG2ProfileSetupViewState {
    var agreements = MG2AgreementState()
    var jobs = [String]()
    var regions = [String]()
    var jobSections = [MG2JobSection]()
    var selectedJob = ""
    var selectedRegion = ""
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

    private static let koreanInitials = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
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
    var availableRegions: [String] { state.regions }

    func resetAgreements() {
        state.agreements = MG2AgreementState()
    }

    func loadConsentItems(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                state.agreements = MG2AgreementState(
                    selections: try await userUseCase.getConsentItems().map {
                        MG2AgreementSelection(item: $0)
                    },
                    hasLoaded: true
                )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func toggleAllAgreements() {
        let newValue = !state.agreements.hasAcceptedAllTerms
        for index in state.agreements.selections.indices {
            state.agreements.selections[index].agreed = newValue
        }
    }

    func toggleAgreement(id: Int) {
        guard let index = state.agreements.selections.firstIndex(
            where: { $0.item.id == id }
        ) else { return }
        state.agreements.selections[index].agreed.toggle()
    }

    func beginJobSelection() {
        state.selectedJob = ""
        updateJobSections(matching: "")
    }

    func updateJobSections(matching query: String) {
        state.jobSections = makeJobSections(matching: query)
    }

    func loadJobs(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                state.jobs = try await userUseCase.getJobs()
                updateJobSections(matching: "")
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
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

    func loadRegions(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                state.regions = try await userUseCase.getAddresses()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func selectRegion(at index: Int) {
        guard state.regions.indices.contains(index) else { return }
        state.selectedRegion = state.regions[index]
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
            return hasNicknameChange
        }
    }

    private func makeJobSections(matching query: String) -> [MG2JobSection] {
        let jobs = query.isEmpty
            ? state.jobs
            : state.jobs.filter { $0.range(of: query, options: .caseInsensitive) != nil }

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
            address: userState.region,
            consents: state.agreements.selections.map {
                MG2ConsentAgreement(consentItemId: $0.item.id, agreed: $0.agreed)
            }
        )
        Task {
            do {
                let result = try await userUseCase.userJoin(registration: registration)
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
