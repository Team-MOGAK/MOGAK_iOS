import Combine
import Foundation

struct MG2JogakOccurrenceItem {
    let key: MG2JogakOccurrenceKey
    let modalartID: Int
    let title: String
    let mogakTitle: String
    let color: String?
    var status: MG2JogakOccurrenceStatus
    let isRoutine: Bool
    /// 이 조각을 완료한 횟수. 체크하면 바로 1 더하고 풀면 뺀다 (축하 카드 "완료한 조각 n회").
    var achievements: Int
    let routineDays: [MG2Weekday]

    var isCompleted: Bool { status == .success }

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
    /// 오늘 조각이 속한 판들의 이번 주 %. 모르면 nil.
    let weeklyPercent: Int?

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
    /// 한 번 불러온 날의 목록 · 진척. 그 날을 다시 고르면 스켈레톤 없이 이걸 먼저 보여 주고 조용히 새로 고친다.
    private var loadedDays = [Date: LoadedDay]()
    /// 지금까지 보낸 불러오기 수.
    private var loadCount = 0
    /// 체크 · 해제한 조각의 내 쪽 상태. 서버 반영 전이거나 반영 전에 보낸 불러오기 응답이면 이걸로 덮어 체크가 풀려 보이지 않게 한다.
    private var localToggles = [MG2JogakOccurrenceKey: LocalToggle]()
    private var toggleVersion = 0

    private struct LoadedDay {
        var occurrences: [MG2JogakOccurrenceItem]
        var progress: MG2TodayProgress?
    }

    private struct LocalToggle {
        let item: MG2JogakOccurrenceItem
        let version: Int
        /// 서버가 받아 준 때의 불러오기 수. 받기 전이면 nil.
        var settledAt: Int?
    }

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

    /// 날을 고른다. 전에 불러온 날이면 그 목록 · 진척으로 바로 바꾸고 true (화면은 곧바로 다시 그린다), 처음이면 false.
    func select(_ date: Date) -> Bool {
        let leaving = Self.calendar.startOfDay(for: state.selectedDate)
        // 떠나는 날의 지금 모습(그사이 체크한 것 포함)을 남겨 둔다.
        if loadedDays[leaving] != nil { loadedDays[leaving] = LoadedDay(occurrences: state.occurrences, progress: state.progress) }
        state.selectedDate = date
        guard let loaded = loadedDays[Self.calendar.startOfDay(for: date)] else { return false }
        state.occurrences = loaded.occurrences
        state.progress = loaded.progress
        return true
    }

    /// 그날 조각을 불러온다. 앱을 켤 때는 스플래시가 기다리는 동안 미리 부른다.
    func load(date: Date) async throws {
        state.selectedDate = date
        guard !isGuest else {
            state.occurrences = []
            state.progress = nil
            loadedDays[Self.calendar.startOfDay(for: date)] = LoadedDay(occurrences: [], progress: nil)
            return
        }
        loadCount += 1
        let loadNumber = loadCount
        let occurrences: [MG2JogakOccurrenceEntity]
        do {
            occurrences = try await useCase.getJogakOccurrences(date: date)
        } catch {
            // 기다리는 사이 다른 날을 골랐으면 그 날 응답이 그린다 (늦게 온 실패로 경고를 띄우지 않는다).
            guard Self.calendar.isDate(state.selectedDate, inSameDayAs: date) else { throw CancellationError() }
            // 다른 날로 바꾸다 실패했으면 앞 날 조각이 새 날 아래 남지 않게 비운다. 보고 있던 날을 새로 고치다 실패하면 그대로 둔다.
            if !hasLoaded(date) {
                state.occurrences = []
                state.progress = nil
            }
            throw error
        }
        // 이 불러오기를 보내기 전에 서버가 받은 체크는 응답에 들어 있다. 그 뒤 것만 내 쪽 상태로 덮는다.
        localToggles = localToggles.filter { ($0.value.settledAt ?? .max) >= loadNumber }
        let items = occurrences.map { entity in
            var item = MG2JogakOccurrenceItem(key: entity.key, modalartID: entity.modalartID, title: entity.title, mogakTitle: entity.mogakTitle, color: entity.color, status: entity.status, isRoutine: entity.isRoutine, achievements: entity.achievements, routineDays: entity.days)
            if let local = localToggles[entity.key]?.item {
                item.status = local.status
                item.achievements = local.achievements
            }
            return item
        }
        let progress = await publishToday(items, date: date)
        // 기다리는 사이 다른 날을 골랐으면 이 응답은 버린다.
        guard Self.calendar.isDate(state.selectedDate, inSameDayAs: date) else { throw CancellationError() }
        // 목록은 기다림이 다 끝난 뒤 한 번에 바꾼다. 중간에 바꾸면 표가 예전 줄 수로 빈 목록을 읽다가 터진다.
        state.occurrences = items
        state.progress = progress
        // ponytail: 본 날만큼 쌓인다(하루 몇 줄). 홈 화면이 새로 만들어지면(다시 로그인) 비워진다.
        loadedDays[Self.calendar.startOfDay(for: date)] = LoadedDay(occurrences: items, progress: progress)
    }

    func hasLoaded(_ date: Date) -> Bool {
        loadedDays[Self.calendar.startOfDay(for: date)] != nil
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
        state.occurrences[index].achievements = max(original.achievements + (isCompleted ? 1 : -1), 0)
        // 기다리는 사이 다른 날로 바꿔도 체크한 날 기준으로 위젯 · 라이브 액티비티를 맞춘다.
        let date = state.selectedDate
        var toggled = state.occurrences
        toggleVersion += 1
        let version = toggleVersion
        localToggles[original.key] = LocalToggle(item: state.occurrences[index], version: version)

        Task {
            do {
                try await useCase.setJogakCompletion(key: original.key, isCompleted: isCompleted)
                if localToggles[original.key]?.version == version { localToggles[original.key]?.settledAt = loadCount }
                await updateProgress(toggled, date: date)
                completion(.success(()))
            } catch {
                // 서버는 바뀌지 않았으니 서버 상태가 맞다.
                if localToggles[original.key]?.version == version { localToggles[original.key] = nil }
                if let currentIndex = state.occurrences.firstIndex(where: { $0.key == original.key }), state.occurrences[currentIndex].status == updatedStatus {
                    state.occurrences[currentIndex].status = original.status
                    state.occurrences[currentIndex].achievements = original.achievements
                }
                if let toggledIndex = toggled.firstIndex(where: { $0.key == original.key }) { toggled[toggledIndex] = original }
                await updateProgress(toggled, date: date)
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

    /// 체크한 날의 조각으로 위젯 · 라이브 액티비티를 맞춘다. 아직 그날을 보고 있으면 지금 목록(그사이 체크한 것 포함)으로 맞추고 진척 카드도 바꾼다.
    private func updateProgress(_ toggled: [MG2JogakOccurrenceItem], date: Date) async {
        let isSameDay = Self.calendar.isDate(state.selectedDate, inSameDayAs: date)
        let progress = await publishToday(isSameDay ? state.occurrences : toggled, date: date)
        if Self.calendar.isDate(state.selectedDate, inSameDayAs: date) {
            state.progress = progress
        } else {
            loadedDays[Self.calendar.startOfDay(for: date)]?.progress = progress
        }
    }

    /// 오늘 조각이면 위젯 · 라이브 액티비티를 맞추고 진척 카드 내용을 돌려준다. 다른 날은 nil.
    private func publishToday(_ items: [MG2JogakOccurrenceItem], date: Date) async -> MG2TodayProgress? {
        guard isToday(date) else { return nil }
        let pieces = items.map {
            MG2TodaySnapshot.Piece(jogakID: $0.key.jogakID, scheduledDate: $0.key.scheduledDate, modalartID: $0.modalartID, title: $0.title, mogakTitle: $0.mogakTitle, color: $0.color, isRoutine: $0.isRoutine, isDone: $0.isCompleted)
        }
        let snapshot = await todayUseCase.publish(pieces)
        return MG2TodayProgress(done: snapshot.done, total: snapshot.total, pose: MG2MoakPose(rawValue: snapshot.pose) ?? .wave, line: snapshot.line, weeklyPercent: snapshot.weeklyPercent)
    }
}
