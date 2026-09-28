import Foundation

struct MG2JobSection {
    let title: String
    let jobs: [String]
}

@MainActor
final class MG2ChooseJobViewModel {
    private static let koreanInitials = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    private let userUseCase: UserUseCase
    private let mode: MG2ProfileSetupMode
    private var jobs = [String]()
    private(set) var sections = [MG2JobSection]()
    private(set) var selectedJob = ""

    init(userUseCase: UserUseCase, mode: MG2ProfileSetupMode) {
        self.userUseCase = userUseCase
        self.mode = mode
    }

    func loadJobs(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                jobs = try await userUseCase.getJobs()
                updateSections(matching: "")
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateSections(matching query: String) {
        let matchedJobs = query.isEmpty ? jobs : jobs.filter { $0.range(of: query, options: .caseInsensitive) != nil }
        let grouped = Dictionary(grouping: matchedJobs, by: Self.sectionTitle)
        sections = grouped.keys.sorted().map { MG2JobSection(title: $0, jobs: grouped[$0] ?? []) }
    }

    func selectJob(section: Int, row: Int) {
        guard sections.indices.contains(section), sections[section].jobs.indices.contains(row) else { return }
        let job = sections[section].jobs[row]
        selectedJob = selectedJob == job ? "" : job
    }

    func submit(completion: @escaping (Result<MG2ProfileSetupResult, Error>) -> Void) {
        let job = selectedJob
        guard !job.isEmpty else { return }
        switch mode {
        case .registration(var draft):
            draft.job = job
            completion(.success(.continueRegistration(draft)))
        case .editing:
            Task {
                do {
                    try await userUseCase.changeJob(job)
                    completion(.success(.profileUpdated))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    private static func sectionTitle(for job: String) -> String {
        guard let scalar = job.unicodeScalars.first else { return "" }
        let value = scalar.value
        guard (0xAC00...0xD7A3).contains(value) else { return job.prefix(1).uppercased() }
        let index = Int((value - 0xAC00) / (21 * 28))
        return koreanInitials[index]
    }
}
