import ActivityKit
import SwiftUI
import WidgetKit

/// 오늘의 조각 라이브 액티비티. 반복 애니메이션 · 광고 없음, 업데이트 때만 포즈와 숫자가 바뀐다.
struct MG2TodayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MG2TodayActivityAttributes.self) { context in
            // 글자 크기는 앱과 같이 accessibility1까지만.
            LockScreenView(state: context.state)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .activityBackgroundTint(Color.white.opacity(0.94))
                .activitySystemActionForegroundColor(MG2WidgetStyle.ink)
        } dynamicIsland: { context in
            let state = context.state
            let tint = MG2WidgetStyle.poseLight(state.pose)
            // `.md-la-exp`: 여백 8 18 12, 64 | 글(eye · head · line) | 76 줄 아래 칸 · 버튼.
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    MG2WidgetStyle.poseImage(state.pose).frame(width: 60, height: 60).frame(width: 64, height: 64)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Score(state: state, color: .white)
                        .frame(width: 76, alignment: .trailing)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                DynamicIslandExpandedRegion(.center) {
                    Summary(state: state, headSize: 17, ink: .white, tint: tint, eyeColor: MG2WidgetStyle.islandSub)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressSegments(state: state, tint: tint, track: Color.white.opacity(0.14))
                        NextPieceButton(state: state, tint: tint, textColor: MG2WidgetStyle.ink)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
            } compactLeading: {
                MG2WidgetStyle.poseImage(state.pose).frame(width: 28, height: 28)
            } compactTrailing: {
                Text("\(state.done)/\(state.total)").font(.pretendard(15, .heavy, relativeTo: .subheadline)).monospacedDigit()
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            } minimal: {
                MinimalRing(state: state, tint: tint)
            }
            .contentMargins(.top, 8, for: .expanded)
            .contentMargins(.horizontal, 18, for: .expanded)
            .contentMargins(.bottom, 12, for: .expanded)
        }
    }
}

/// 잠금 화면 (`.md-la-lock`): 여백 14 · 사이 10, 줄은 56 | 글 | 점수 사이 12. 다이나믹 아일랜드가 없는 기기도 이 모양 배너로 보인다.
private struct LockScreenView: View {
    let state: MG2TodayActivityAttributes.ContentState

    var body: some View {
        let deep = MG2WidgetStyle.poseDeep(state.pose)
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                MG2WidgetStyle.poseImage(state.pose).frame(width: 56, height: 56)
                Summary(state: state, headSize: 16, ink: MG2WidgetStyle.ink, tint: deep, eyeColor: MG2WidgetStyle.muted)
                Score(state: state, color: MG2WidgetStyle.ink).layoutPriority(1)
            }
            ProgressSegments(state: state, tint: deep, track: MG2WidgetStyle.track)
            NextPieceButton(state: state, tint: deep, textColor: .white)
        }
        .padding(14)
    }
}

/// eye 12/600 · head 800 한 줄 말줄임 · line 13/700 (`.md-la-eye/head/line`). eyeColor가 nil이면 eye 줄을 뺀다.
private struct Summary: View {
    let state: MG2TodayActivityAttributes.ContentState
    let headSize: CGFloat
    let ink: Color
    let tint: Color
    let eyeColor: Color?

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if let eyeColor {
                Text("오늘의 조각").font(.pretendard(12, .semibold, relativeTo: .caption)).foregroundStyle(eyeColor)
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            Text(state.nextTitle.map { "다음 · \($0)" } ?? "오늘 조각 모두 완료!")
                .font(.pretendard(headSize, .heavy, relativeTo: .headline)).foregroundStyle(ink)
                .lineLimit(1).truncationMode(.tail)
            Text(state.line).font(.pretendard(13, .bold, relativeTo: .footnote)).foregroundStyle(tint)
                .lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// n/m 30/800 고정폭 숫자 + "오늘" 11/700 (`.md-la-score`).
private struct Score: View {
    let state: MG2TodayActivityAttributes.ContentState
    let color: Color

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(state.done)/\(state.total)").font(.pretendard(30, .heavy, relativeTo: .largeTitle)).monospacedDigit()
                .contentTransition(.numericText())
            Text("오늘").font(.pretendard(11, .bold, relativeTo: .caption2)).opacity(0.7)
        }
        .foregroundStyle(color)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
}

/// 조각 하나에 한 칸 (`.md-la-segs`, 높이 8 · 사이 4).
private struct ProgressSegments: View {
    let state: MG2TodayActivityAttributes.ContentState
    let tint: Color
    let track: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(state.total, 1), id: \.self) { index in
                Capsule().fill(index < state.done ? tint : track).frame(height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

/// 버튼은 "다음 조각 완료" 하나 (`.md-la-btn` 44 · 모서리 14 · 15/800). 모두 끝나면 버튼을 숨긴다.
private struct NextPieceButton: View {
    let state: MG2TodayActivityAttributes.ContentState
    let tint: Color
    let textColor: Color

    var body: some View {
        if let next = state.nextTitle {
            Button(intent: MG2CompleteNextPieceIntent()) {
                // 긴 조각 이름만 말줄임하고 "’ 완료"는 남긴다.
                HStack(spacing: 0) {
                    Text("‘\(next)").lineLimit(1).truncationMode(.tail)
                    Text("’ 완료").fixedSize()
                }
                .font(.pretendard(15, .heavy, relativeTo: .subheadline))
                .foregroundStyle(textColor)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

/// minimal: 진척 링(두께 3) + 모각이 21.
private struct MinimalRing: View {
    let state: MG2TodayActivityAttributes.ContentState
    let tint: Color

    var body: some View {
        ZStack {
            Circle().inset(by: 1.5).stroke(Color.white.opacity(0.18), lineWidth: 3)
            Circle().inset(by: 1.5).trim(from: 0, to: Double(state.done) / Double(max(state.total, 1)))
                .stroke(tint, lineWidth: 3)
                .rotationEffect(.degrees(-90))
            MG2WidgetStyle.poseImage(state.pose).frame(width: 21, height: 21)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("오늘의 조각 \(state.done) / \(state.total)")
    }
}
