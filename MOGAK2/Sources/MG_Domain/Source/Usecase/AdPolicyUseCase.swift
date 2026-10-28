import Foundation

/// 지난 날 기록을 체크할 수 있는지. 어제는 무료, 7일 안은 보상형 광고, 그 전은 읽기 전용.
enum MG2PastDayAccess: Equatable {
    case editable
    case rewardRequired
    case readOnly
}

/// AdMob 노출 규칙. 화면은 이 결과만 보고 광고를 띄운다.
final class AdPolicyUseCase {
    static let interstitialDailyLimit = 2
    static let interstitialInterval: TimeInterval = 5 * 60
    static let appOpenAwayInterval: TimeInterval = 4 * 60 * 60
    static let rewardWindowDays = 7

    private let storage: AdPolicyStorage
    private let calendar: Calendar
    private let now: () -> Date

    init(storage: AdPolicyStorage, calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.storage = storage
        self.calendar = calendar
        self.now = now
    }

    /// 앱을 켤 때마다 부른다. 처음이면 설치일을 남긴다. 첫 실행이면 true.
    @discardableResult
    func registerLaunch() -> Bool {
        guard storage.installDate == nil else { return false }
        storage.installDate = now()
        return true
    }

    /// 설치한 날이 1일째.
    var installDay: Int {
        guard let installDate = storage.installDate else { return 1 }
        return days(from: installDate, to: now()) + 1
    }

    /// 네이티브: 홈 목록 맨 끝, 설치 2일째부터.
    var canShowNativeAd: Bool { installDay >= 2 }

    /// 배너: 마이페이지 맨 아래. 첫 실행 날에는 띄우지 않는다.
    var canShowBanner: Bool { installDay >= 2 }

    /// 전면: 3일째부터 · 하루 2회 · 5분 간격.
    var canShowInterstitial: Bool {
        guard installDay >= 3 else { return false }
        let today = storage.interstitialDates.filter { calendar.isDate($0, inSameDayAs: now()) }
        guard today.count < Self.interstitialDailyLimit else { return false }
        guard let last = today.max() else { return true }
        return now().timeIntervalSince(last) >= Self.interstitialInterval
    }

    func didShowInterstitial() {
        storage.interstitialDates = storage.interstitialDates.filter { calendar.isDate($0, inSameDayAs: now()) } + [now()]
    }

    func didEnterBackground() {
        storage.lastBackgroundDate = now()
    }

    /// 앱 열기: 4시간 만에 다시 열 때, 하루 1회. 첫 실행 날에는 띄우지 않는다.
    var canShowAppOpenAd: Bool {
        guard installDay >= 2, let background = storage.lastBackgroundDate else { return false }
        guard now().timeIntervalSince(background) >= Self.appOpenAwayInterval else { return false }
        if let last = storage.lastAppOpenAdDate, calendar.isDate(last, inSameDayAs: now()) { return false }
        return true
    }

    func didShowAppOpenAd() {
        storage.lastAppOpenAdDate = now()
    }

    func pastDayAccess(for date: Date) -> MG2PastDayAccess {
        let age = days(from: date, to: now())
        if age <= 1 { return .editable }
        if age > Self.rewardWindowDays { return .readOnly }
        return storage.unlockedPastDays.contains(calendar.startOfDay(for: date)) ? .editable : .rewardRequired
    }

    /// 보상형 광고를 끝까지 본 날은 계속 열어 둔다. 7일이 지난 날은 어차피 읽기 전용이라 지운다.
    func unlockPastDay(_ date: Date) {
        let kept = storage.unlockedPastDays.filter { days(from: $0, to: now()) <= Self.rewardWindowDays }
        storage.unlockedPastDays = Array(Set(kept + [calendar.startOfDay(for: date)]))
    }

    private func days(from start: Date, to end: Date) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day ?? 0
    }
}
