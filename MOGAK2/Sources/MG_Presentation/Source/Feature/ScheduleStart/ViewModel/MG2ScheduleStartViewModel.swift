import Combine
import Foundation

struct MG2JogakOccurrenceItem {
    let key: MG2JogakOccurrenceKey
    let title: String
    let mogakTitle: String
    let color: String?
    var status: MG2JogakOccurrenceStatus
    let isRoutine: Bool
    let achievements: Int
    /// 루틴 반복 요일. 못 불러오면 비어 있고 "루틴"만 보인다.
    var routineDays = [MG2Weekday]()

    var isCompleted: Bool { status == .success }

    /// 스켈레톤 자리 표시용 행. 글자 폭만 잡아 주면 된다.
    static let placeholder = MG2JogakOccurrenceItem(key: MG2JogakOccurrenceKey(jogakID: 0, scheduledDate: Date()), title: "오늘의 조각 이름", mogakTitle: "모각", color: nil, status: .pending, isRoutine: false, achievements: 0)
    static let placeholderCount = 3
    var detail: String {
        guard isRoutine else { return "오늘만" }
        let days = routineDays.sorted { $0.rawValue < $1.rawValue }.map(\.shortKoreanTitle)
        return days.isEmpty ? "루틴" : "루틴 · " + days.joined(separator: "·")
    }
}

/// 진척 카드에 그릴 오늘 상태.
struct MG2TodayProgress {
    let done: Int
    let total: Int
    let pose: MG2MoakPose
    let line: String

    /// 스켈레톤 자리 표시용.
    static let placeholder = MG2TodayProgress(done: 0, total: 5, pose: .wave, line: "오늘의 조각을 불러오고 있어요")

    var isAllDone: Bool { total > 0 && done >= total }
    var percent: Int { total == 0 ? 0 : Int((Double(done) / Double(total) * 100).rounded()) }
}

struct MG2ScheduleStartViewState {
    var selectedDate = Date()
    var occurrences = [MG2JogakOccurrenceItem]()
    var progress: MG2TodayProgress?

    var isEmpty: Bool { occurrences.isEmpty }
}

/// 조각 체크 결과. 화면은 이걸 보고 토스트 · 축하 카드 · 광고 안내를 고른다.
enum MG2JogakToggleOutcome {
    case toggled(isCompleted: Bool, remaining: Int)
    case completedAll
    case readOnly
    case rewardRequired
}

@MainActor
final class MG2ScheduleStartViewModel {
    /// 달력은 그레고리력 · 한국어 · 일요일 시작 (예전 달력과 같다).
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()

    private static let calendarHeaderFormatter = makeFormatter("yyyy년 M월")

    private static func makeFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.dateFormat = format
        return formatter
    }

    private let useCase: ScheduleStartUseCase
    private let todayUseCase: TodayUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let userState: MG2UserState
    private(set) var state = MG2ScheduleStartViewState()
    /// 마지막으로 불러온 날. 같은 날을 다시 불러올 때는 화면을 덮지 않는다.
    private var loadedDate: Date?

    /// 위젯 · 라이브 액티비티에서 조각이 바뀌었을 때.
    var externalChanges: AnyPublisher<Void, Never> {
        todayUseCase.externalChanges.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    init(useCase: ScheduleStartUseCase, todayUseCase: TodayUseCase, adPolicyUseCase: AdPolicyUseCase, userState: MG2UserState) {
        self.useCase = useCase
        self.todayUseCase = todayUseCase
        self.adPolicyUseCase = adPolicyUseCase
        self.userState = userState
    }

    var isGuest: Bool { userState.loginState == .guest }
    var isSelectedDateToday: Bool { isToday(state.selectedDate) }
    var canShowNativeAd: Bool { isSelectedDateToday && !state.isEmpty && adPolicyUseCase.canShowNativeAd }
    var canShowInterstitial: Bool { adPolicyUseCase.canShowInterstitial }
    var shouldOfferReminder: Bool { todayUseCase.shouldOfferReminder }
    var completedPieceCount: Int { state.occurrences.reduce(0) { $0 + $1.achievements } }

    func isToday(_ date: Date) -> Bool {
        todayUseCase.isToday(date)
    }

    func calendarHeader(for date: Date) -> String {
        Self.calendarHeaderFormatter.string(from: date)
    }

    func loadJogakOccurrences(date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await load(date: date)
                completion(.success(()))
            } catch is CancellationError {
                // 더 나중에 고른 날의 응답이 그린다.
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 그날 조각을 불러온다. 앱을 켤 때는 스플래시가 기다리는 동안 미리 부른다.
    func load(date: Date) async throws {
        state.selectedDate = date
        guard !isGuest else {
            state.occurrences = []
            state.progress = nil
            loadedDate = date
            return
        }
        let occurrences = try await useCase.getJogakOccurrences(date: date)
        // 요일은 보조 정보라 못 불러와도 목록은 보여 준다.
        let routineDays = (try? await useCase.routineWeekdays(for: occurrences)) ?? [:]
        // 기다리는 사이 다른 날을 골랐으면 이 응답은 버린다.
        guard Self.calendar.isDate(state.selectedDate, inSameDayAs: date) else { throw CancellationError() }
        state.occurrences = occurrences.map {
            MG2JogakOccurrenceItem(key: $0.key, title: $0.title, mogakTitle: $0.mogakTitle, color: $0.color, status: $0.status, isRoutine: $0.isRoutine, achievements: $0.achievements, routineDays: routineDays[$0.key.jogakID] ?? [])
        }
        await publishTodayIfNeeded()
        loadedDate = date
    }

    func hasLoaded(_ date: Date) -> Bool {
        loadedDate.map { Self.calendar.isDate($0, inSameDayAs: date) } ?? false
    }

    /// 지난 날은 읽기 전용, 어제는 무료, 7일 안은 보상형 광고를 본 뒤에 체크한다.
    func toggleJogakCompletion(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) -> MG2JogakToggleOutcome? {
        guard state.occurrences.indices.contains(index) else { return nil }
        switch adPolicyUseCase.pastDayAccess(for: state.selectedDate) {
        case .readOnly: return .readOnly
        case .rewardRequired: return .rewardRequired
        case .editable: break
        }

        let original = state.occurrences[index]
        let isCompleted = !original.isCompleted
        let updatedStatus: MG2JogakOccurrenceStatus = isCompleted ? .success : .fail
        state.occurrences[index].status = updatedStatus

        Task {
            do {
                try await useCase.setJogakCompletion(key: original.key, isCompleted: isCompleted)
                await publishTodayIfNeeded()
                completion(.success(()))
            } catch {
                if let currentIndex = state.occurrences.firstIndex(where: { $0.key == original.key }), state.occurrences[currentIndex].status == updatedStatus {
                    state.occurrences[currentIndex].status = original.status
                }
                await publishTodayIfNeeded()
                completion(.failure(error))
            }
        }

        let remaining = state.occurrences.filter { !$0.isCompleted }.count
        if isCompleted, remaining == 0, isSelectedDateToday { return .completedAll }
        return .toggled(isCompleted: isCompleted, remaining: remaining)
    }

    func unlockSelectedDay() {
        adPolicyUseCase.unlockPastDay(state.selectedDate)
    }

    func didShowInterstitial() {
        adPolicyUseCase.didShowInterstitial()
    }

    func enableReminder() {
        Task { _ = await todayUseCase.enableReminder() }
    }

    func declineReminder() {
        todayUseCase.declineReminder()
    }

    func getJogakForEditing(jogakId: Int, completion: @escaping (Result<MG2JogakDetailEntity, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await useCase.getJogakDetail(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 오늘을 보고 있을 때만 진척 카드 · 위젯 · 라이브 액티비티를 맞춘다.
    private func publishTodayIfNeeded() async {
        guard isSelectedDateToday else {
            state.progress = nil
            return
        }
        let pieces = state.occurrences.map {
            MG2TodaySnapshot.Piece(jogakID: $0.key.jogakID, scheduledDate: $0.key.scheduledDate, title: $0.title, mogakTitle: $0.mogakTitle, color: $0.color, isRoutine: $0.isRoutine, isDone: $0.isCompleted)
        }
        let snapshot = await todayUseCase.publish(pieces)
        state.progress = MG2TodayProgress(done: snapshot.done, total: snapshot.total, pose: MG2MoakPose(rawValue: snapshot.pose) ?? .wave, line: snapshot.line)
    }
}
