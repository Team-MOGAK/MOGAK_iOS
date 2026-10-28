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

    var isCompleted: Bool { status == .success }
    var detail: String { isRoutine ? "루틴" : "오늘만" }
}

/// 진척 카드에 그릴 오늘 상태.
struct MG2TodayProgress {
    let done: Int
    let total: Int
    let pose: MG2MoakPose
    let line: String

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
    private static let calendarHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    private let useCase: ScheduleStartUseCase
    private let todayUseCase: TodayUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let userState: MG2UserState
    private(set) var state = MG2ScheduleStartViewState()

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
    var isSelectedDateToday: Bool { todayUseCase.isToday(state.selectedDate) }
    var canShowNativeAd: Bool { isSelectedDateToday && !state.isEmpty && adPolicyUseCase.canShowNativeAd }
    var canShowInterstitial: Bool { adPolicyUseCase.canShowInterstitial }
    var shouldOfferReminder: Bool { todayUseCase.shouldOfferReminder }
    var completedPieceCount: Int { state.occurrences.reduce(0) { $0 + $1.achievements } }

    func calendarHeader(for date: Date) -> String {
        Self.calendarHeaderFormatter.string(from: date)
    }

    func isToday(_ date: Date) -> Bool {
        todayUseCase.isToday(date)
    }

    func calendarPage(from currentPage: Date, offset: Int, isWeekly: Bool) -> Date? {
        let component: Calendar.Component = isWeekly ? .weekOfMonth : .month
        return Calendar.current.date(byAdding: component, value: offset, to: currentPage)
    }

    func loadJogakOccurrences(date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        state.selectedDate = date
        guard !isGuest else {
            state.occurrences = []
            state.progress = nil
            completion(.success(()))
            return
        }

        Task {
            do {
                state.occurrences = try await useCase.getJogakOccurrences(date: date).map {
                    MG2JogakOccurrenceItem(key: $0.key, title: $0.title, mogakTitle: $0.mogakTitle, color: $0.color, status: $0.status, isRoutine: $0.isRoutine, achievements: $0.achievements)
                }
                await publishTodayIfNeeded()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
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
