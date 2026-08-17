import Foundation

struct MG2JogakOccurrenceItem {
    let key: MG2JogakOccurrenceKey
    let title: String
    var status: MG2JogakOccurrenceStatus
    let isRoutine: Bool

    var isCompleted: Bool { status == .success }
}

struct MG2ScheduleStartViewState {
    var selectedDate = Date()
    var occurrences = [MG2JogakOccurrenceItem]()

    var isEmpty: Bool { occurrences.isEmpty }
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

    func loadJogakOccurrences(
        date: Date,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        state.selectedDate = date
        guard !isGuest else {
            state.occurrences = []
            completion(.success(()))
            return
        }

        Task {
            do {
                state.occurrences = try await useCase.getJogakOccurrences(date: date).map {
                    MG2JogakOccurrenceItem(
                        key: $0.key,
                        title: $0.title,
                        status: $0.status,
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
    func toggleJogakCompletion(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Bool? {
        guard state.occurrences.indices.contains(index) else { return nil }
        let original = state.occurrences[index]

        let isCompleted = !original.isCompleted
        let updatedStatus: MG2JogakOccurrenceStatus = isCompleted ? .success : .fail
        state.occurrences[index].status = updatedStatus

        Task {
            do {
                try await useCase.setJogakCompletion(
                    key: original.key,
                    isCompleted: isCompleted
                )
                completion(.success(()))
            } catch {
                if let currentIndex = state.occurrences.firstIndex(where: {
                    $0.key == original.key
                }), state.occurrences[currentIndex].status == updatedStatus {
                    state.occurrences[currentIndex].status = original.status
                }
                completion(.failure(error))
            }
        }
        return isCompleted
    }

    func getJogakForEditing(
        jogakId: Int,
        completion: @escaping (Result<MG2JogakDetailEntity, Error>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await useCase.getJogakDetail(jogakId: jogakId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
