import ActivityKit
import SwiftUI
import WidgetKit

/// 오늘의 조각 라이브 액티비티. 반복 애니메이션 · 광고 없음, 업데이트 때만 포즈와 숫자가 바뀐다.
struct MG2TodayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MG2TodayActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color.white.opacity(0.94))
                .activitySystemActionForegroundColor(MG2WidgetStyle.ink)
        } dynamicIsland: { context in
            let state = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(MG2WidgetStyle.poseImage(state.pose)).resizable().scaledToFit().frame(width: 60, height: 60)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(state.done)/\(state.total)").font(.pretendard(20, .heavy, relativeTo: .title3)).monospacedDigit()
                        .foregroundStyle(MG2WidgetStyle.poseLight(state.pose))
                        .contentTransition(.numericText())
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(state.line).font(.pretendard(15, .bold, relativeTo: .subheadline)).foregroundStyle(.white).lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressSegments(state: state, tint: MG2WidgetStyle.poseLight(state.pose), track: Color.white.opacity(0.18))
                        NextPieceButton(state: state, tint: MG2WidgetStyle.poseLight(state.pose), textColor: MG2WidgetStyle.ink, subColor: MG2WidgetStyle.islandSub)
                    }
                    .padding(.horizontal, 6)
                }
            } compactLeading: {
                Image(MG2WidgetStyle.poseImage(state.pose)).resizable().scaledToFit().frame(width: 28, height: 28)
            } compactTrailing: {
                Text("\(state.done)/\(state.total)").font(.pretendard(12, .heavy, relativeTo: .caption)).monospacedDigit()
                    .foregroundStyle(MG2WidgetStyle.poseLight(state.pose))
            } minimal: {
                Image(MG2WidgetStyle.poseImage(state.pose)).resizable().scaledToFit().frame(width: 18, height: 18)
            }
        }
    }
}

/// 잠금 화면 (`.md-la-lock`): 여백 14 · 사이 10. 다이나믹 아일랜드가 없는 기기도 이 모양 배너로 보인다.
private struct LockScreenView: View {
    let state: MG2TodayActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(MG2WidgetStyle.poseImage(state.pose)).resizable().scaledToFit().frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text("오늘의 조각").font(.pretendard(12, .semibold, relativeTo: .caption)).foregroundStyle(MG2WidgetStyle.sub)
                    Text(state.nextTitle.map { "다음 ‘\($0)’" } ?? "오늘 몫 다 채웠어요")
                        .font(.pretendard(17, .heavy, relativeTo: .headline)).foregroundStyle(MG2WidgetStyle.ink).lineLimit(1)
                    Text(state.line).font(.pretendard(13, .bold, relativeTo: .footnote)).foregroundStyle(MG2WidgetStyle.poseDeep(state.pose))
                }
                Spacer(minLength: 0)
                Text("\(state.done)/\(state.total)")
                    .font(.pretendard(30, .heavy, relativeTo: .largeTitle)).monospacedDigit()
                    .foregroundStyle(MG2WidgetStyle.poseDeep(state.pose))
                    .contentTransition(.numericText())
            }
            ProgressSegments(state: state, tint: MG2WidgetStyle.poseDeep(state.pose), track: MG2WidgetStyle.track)
            NextPieceButton(state: state, tint: MG2WidgetStyle.poseDeep(state.pose), textColor: .white, subColor: MG2WidgetStyle.sub)
        }
        .padding(14)
    }
}

/// 조각 하나에 한 칸 (`.md-la-segs`, 8pt).
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

/// 버튼은 "다음 조각 완료" 하나.
private struct NextPieceButton: View {
    let state: MG2TodayActivityAttributes.ContentState
    let tint: Color
    let textColor: Color
    let subColor: Color

    var body: some View {
        if let next = state.nextTitle {
            Button(intent: MG2CompleteNextPieceIntent()) {
                Text("‘\(next)’ 완료")
                    .font(.pretendard(15, .heavy, relativeTo: .subheadline))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .foregroundStyle(textColor)
                    .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        } else {
            Text("오늘 몫 다 채웠어요").font(.pretendard(13, .bold, relativeTo: .footnote)).foregroundStyle(subColor)
        }
    }
}
