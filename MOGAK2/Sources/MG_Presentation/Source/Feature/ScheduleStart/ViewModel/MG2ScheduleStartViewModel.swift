import Foundation

struct MG2DailyJogakItem {
    let title: String
    let dailyJogakID: Int
    let jogakID: Int?
    var isAchievement: Bool
    let isRoutine: Bool

    var isReadOnly: Bool {
        dailyJogakID <= 0 || jogakID == nil
    }
}

struct MG2ScheduleStartViewState {
    var selectedDate = Date()
    var dailyJogaks = [MG2DailyJogakItem]()

    var isEmpty: Bool { dailyJogaks.isEmpty }
}

@MainActor
final class MG2ScheduleStartViewModel {
    private static let calendarHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }()

    private let useCase: ScheduleStartUseCase
    private let userState: MG2UserState
    private(set) var state = MG2ScheduleStartViewState()

    init(
        useCase: ScheduleStartUseCase,
        userState: MG2UserState
    ) {
        self.useCase = useCase
        self.userState = userState
    }

    var isGuest: Bool { userState.loginState == .guest }

    func calendarHeader(for date: Date) -> String {
        Self.calendarHeaderFormatter.string(from: date)
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    func calendarPage(from currentPage: Date, offset: Int, isWeekly: Bool) -> Date? {
        let component: Calendar.Component = isWeekly ? .weekOfMonth : .month
        return Calendar.current.date(byAdding: component, value: offset, to: currentPage)
    }

    func loadDailyJogaks(
        date: Date,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        state.selectedDate = date
        guard !isGuest else {
            state.dailyJogaks = []
            completion(.success(()))
            return
        }

        Task {
            do {
                state.dailyJogaks = try await useCase.getDailyJogaks(date: date).map {
                    MG2DailyJogakItem(
                        title: $0.title,
                        dailyJogakID: $0.dailyID,
                        jogakID: $0.id,
                        isAchievement: $0.isAchievement,
                        isRoutine: $0.isRoutine
                    )
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func toggleJogakAchievement(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Bool? {
        guard state.dailyJogaks.indices.contains(index) else { return nil }
        let original = state.dailyJogaks[index]
        guard !original.isReadOnly else { return nil }

        let updatedValue = !original.isAchievement
        state.dailyJogaks[index].isAchievement = updatedValue

        Task {
            do {
                try await useCase.setJogakAchievement(
                    dailyJogakId: original.dailyJogakID,
                    isAchievement: updatedValue
                )
                completion(.success(()))
            } catch {
                if let currentIndex = state.dailyJogaks.firstIndex(where: {
                    $0.dailyJogakID == original.dailyJogakID
                }), state.dailyJogaks[currentIndex].isAchievement == updatedValue {
                    state.dailyJogaks[currentIndex].isAchievement = original.isAchievement
                }
                completion(.failure(error))
            }
        }
        return updatedValue
    }

    func getJogakForEditing(
        jogakId: Int,
        completion: @escaping (Result<MG2JogakDetailEntity?, Error>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await useCase.getDailyJogakDetail(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
