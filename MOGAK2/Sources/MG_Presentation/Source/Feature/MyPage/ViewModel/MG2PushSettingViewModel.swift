import Foundation

@MainActor
final class MG2PushSettingViewModel {
    /// 아티팩트 Chip 예시와 같은 세 시각.
    let timeOptions: [(title: String, time: DateComponents)] = [("오전 8시", DateComponents(hour: 8, minute: 0)), ("낮 12시", DateComponents(hour: 12, minute: 0)), ("오후 9시", DateComponents(hour: 21, minute: 0))]

    private let todayUseCase: TodayUseCase
    private(set) var isOn = false
    private(set) var time = DateComponents(hour: 8, minute: 0)
    /// 켜려고 했는데 기기 설정에서 알림이 막혀 있을 때.
    private(set) var isDenied = false

    var selectedTimeIndex: Int? {
        timeOptions.firstIndex { $0.time.hour == time.hour && $0.time.minute == time.minute }
    }

    init(todayUseCase: TodayUseCase) {
        self.todayUseCase = todayUseCase
    }

    func load(completion: @escaping () -> Void) {
        Task {
            (isOn, time) = await todayUseCase.reminderSettings()
            completion()
        }
    }

    func update(isOn: Bool, time: DateComponents, completion: @escaping () -> Void) {
        Task {
            let scheduled = await todayUseCase.updateReminder(isOn: isOn, time: time)
            self.isOn = scheduled
            self.time = time
            isDenied = isOn && !scheduled
            completion()
        }
    }
}
