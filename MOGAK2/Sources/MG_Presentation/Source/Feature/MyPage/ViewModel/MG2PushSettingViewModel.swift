import Foundation

@MainActor
final class MG2PushSettingViewModel {
    private let todayUseCase: TodayUseCase
    private(set) var isOn = false
    private(set) var time = DateComponents(hour: 9, minute: 0)
    /// 켜려고 했는데 기기 설정에서 알림이 막혀 있을 때.
    private(set) var isDenied = false

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
