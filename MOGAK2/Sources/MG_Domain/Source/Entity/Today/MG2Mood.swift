import Foundation

/// 모각이 포즈 12종. 이름은 에셋(moak.<포즈>)과 같다.
enum MG2MoakPose: String, CaseIterable {
    case wave, wink, peace, thumbs, fighting, proud, love, dizzy, hurry, think, sweat, tired

    /// 누를 때마다 차례로 바뀌는 반응 포즈와 말풍선.
    static let reactions: [(pose: MG2MoakPose, bubble: String)] = [
        (.love, "오늘도 같이 해요!"), (.wink, "하나씩 해치우자"), (.fighting, "할 수 있어요"), (.dizzy, "간지러워요~")
    ]
}

/// 오늘의 조각 진척에 따른 모각이 상태. 앱 · 위젯 · 라이브 액티비티가 같은 규칙(moodOf · poseOf · moodLine)을 쓴다.
enum MG2Mood: Equatable {
    case morning, progress, last, done, evening, missed, timer

    static let eveningHour = 18

    init(done: Int, total: Int, isEvening: Bool = false, missedYesterday: Bool = false, isTimerRunning: Bool = false) {
        if isTimerRunning {
            self = .timer
        } else if total > 0 && done >= total {
            self = .done
        } else if isEvening && total > 0 {
            self = .evening
        } else if done == 0 {
            self = missedYesterday ? .missed : .morning
        } else if done == total - 1 {
            self = .last
        } else {
            self = .progress
        }
    }

    func pose(done: Int, total: Int) -> MG2MoakPose {
        switch self {
        case .morning: return .wave
        case .progress: return [.wave, .wink, .peace, .thumbs][min(max(done, 0), 3)]
        case .last: return .fighting
        case .done: return .proud
        case .evening: return total - done >= 3 ? .sweat : .think
        case .missed: return .tired
        case .timer: return .hurry
        }
    }

    func line(done: Int, total: Int) -> String {
        switch self {
        case .morning: return "오늘 조각 \(total)개, 시작해 볼까요?"
        case .progress: return done >= 3 ? "엄지척! \(done)개 끝" : "좋아요, \(done)개 했어요!"
        case .last: return "하나만 더! 거의 다 왔어요"
        case .done: return "오늘 몫 다 채웠어요"
        case .evening: return "오늘 \(max(total - done, 0))개 남았어요"
        case .missed: return "어제는 쉬었어요. 오늘 다시 시작!"
        case .timer: return "집중하는 중"
        }
    }
}
