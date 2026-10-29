import SwiftUI
import WidgetKit

struct MG2TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: MG2TodaySnapshot?
}

struct MG2TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> MG2TodayEntry {
        MG2TodayEntry(date: Date(), snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MG2TodayEntry) -> Void) {
        completion(MG2TodayEntry(date: Date(), snapshot: .load(for: Date())))
    }

    /// 자정에 앱이 미리 둔 내일 조각으로 바뀐다. 그것도 없으면 앱을 열 때까지 빈 상태.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MG2TodayEntry>) -> Void) {
        let now = Date()
        // 24시간을 더하면 서머타임이 바뀌는 날 자정을 놓친다. 오늘 0시에 하루를 더한다.
        let midnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now)) ?? now.addingTimeInterval(86_400)
        let entries = [MG2TodayEntry(date: now, snapshot: .load(for: now)), MG2TodayEntry(date: midnight, snapshot: .load(for: midnight))]
        completion(Timeline(entries: entries, policy: .after(midnight)))
    }
}

struct MG2TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MG2TodayWidget", provider: MG2TodayProvider()) { entry in
            // 여백은 시스템 기본 대신 `.md-widget` 14. 글자 크기는 앱과 같이 accessibility1까지만.
            MG2TodayWidgetView(entry: entry)
                .padding(14)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .containerBackground(MG2WidgetStyle.surface, for: .widget)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("오늘의 조각")
        .description("오늘 할 조각을 보고 바로 체크해요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// 위젯에는 광고가 없다.
struct MG2TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MG2TodayEntry

    var body: some View {
        if let snapshot = entry.snapshot, snapshot.total > 0 {
            if family == .systemSmall {
                MiniBoard(snapshot: snapshot)
            } else {
                TodayList(snapshot: snapshot)
            }
        } else {
            VStack(spacing: 6) {
                MG2WidgetStyle.poseImage("wave").frame(maxWidth: 56, maxHeight: 56)
                // 요약이 있는데 0개면 정말 오늘 조각이 없는 것이다.
                Text(entry.snapshot == nil ? "앱을 열어 오늘의 조각을 불러와요" : "오늘의 조각이 없어요")
                    .font(.pretendard(13, .medium, relativeTo: .footnote))
                    .foregroundStyle(MG2WidgetStyle.sub)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

/// 소형: 미니 판(사이 3 · 모서리 6) + 제목 · % 줄(13/800). 가운데는 오늘 n/m, 둘레는 모각별 오늘 진척.
private struct MiniBoard: View {
    let snapshot: MG2TodaySnapshot

    private var mogaks: [(title: String, color: String?, ratio: Double)] {
        var order = [String]()
        var groups = [String: [MG2TodaySnapshot.Piece]]()
        for piece in snapshot.pieces {
            if groups[piece.mogakTitle] == nil { order.append(piece.mogakTitle) }
            groups[piece.mogakTitle, default: []].append(piece)
        }
        return order.prefix(8).map { title in
            let pieces = groups[title] ?? []
            return (title, pieces.first?.color, Double(pieces.filter(\.isDone).count) / Double(max(pieces.count, 1)))
        }
    }

    private var percent: Int { Int((Double(snapshot.done) / Double(max(snapshot.total, 1)) * 100).rounded()) }

    var body: some View {
        let cells = mogaks
        VStack(spacing: 8) {
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                ForEach(0..<3, id: \.self) { row in
                    GridRow {
                        ForEach(0..<3, id: \.self) { column in
                            cell(at: row * 3 + column, cells: cells)
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("오늘의 조각").foregroundStyle(MG2WidgetStyle.ink).minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                // 아티팩트는 판 이름 + 이번 주 %. 둘 다 아직 데이터가 없어 오늘 n/m을 둔다 (TODO(server): 주간 진척).
                Text("\(snapshot.done)/\(snapshot.total)").monospacedDigit()
                    .foregroundStyle(MG2WidgetStyle.accent)
                    .contentTransition(.numericText())
                    .layoutPriority(1)
            }
            .font(.pretendard(13, .heavy, relativeTo: .footnote))
            .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("오늘의 조각 \(snapshot.done) / \(snapshot.total)")
    }

    @ViewBuilder
    private func cell(at index: Int, cells: [(title: String, color: String?, ratio: Double)]) -> some View {
        let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)
        if index == 4 {
            shape.fill(MG2WidgetStyle.accent)
                .overlay(
                    // 가운데 칸은 오늘 % (아티팩트 Widget small).
                    Text("\(percent)%").font(.pretendard(11, .heavy, relativeTo: .caption2)).monospacedDigit().foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 2)
                        .contentTransition(.numericText())
                )
        } else {
            let mogakIndex = index < 4 ? index : index - 1
            if cells.indices.contains(mogakIndex) {
                // 모각 색(deep) 진하기가 오늘 진척: 0.16 + 0.84 × 비율.
                shape.fill(MG2WidgetStyle.moak(for: cells[mogakIndex].color).deep.opacity(0.16 + 0.84 * cells[mogakIndex].ratio))
            } else {
                shape.fill(MG2WidgetStyle.canvas)
            }
        }
    }
}

/// 중형: 왼쪽 92(오늘 n/m · 막대 6 · 모각이) + 조각 체크 4줄(줄 최소 28 · 체크 원 20).
private struct TodayList: View {
    let snapshot: MG2TodaySnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("오늘의 조각").font(.pretendard(12, .bold, relativeTo: .caption)).foregroundStyle(MG2WidgetStyle.sub)
                Text("\(snapshot.done)/\(snapshot.total)").font(.pretendard(28, .heavy, relativeTo: .title)).monospacedDigit().foregroundStyle(MG2WidgetStyle.ink)
                    .contentTransition(.numericText())
                Capsule().fill(MG2WidgetStyle.track).frame(height: 6)
                    .overlay(alignment: .leading) {
                        GeometryReader { proxy in
                            Capsule().fill(MG2WidgetStyle.accent).frame(width: proxy.size.width * Double(snapshot.done) / Double(snapshot.total))
                        }
                    }
                Spacer(minLength: 0)
                // 디자인의 "이번 주 n%" 자리. 주간 진척은 서버 값이 없어 모각이를 둔다.
                MG2WidgetStyle.poseImage(snapshot.pose).frame(maxWidth: 52, maxHeight: 52)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(width: 92, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(snapshot.pieces.prefix(4).enumerated()), id: \.offset) { _, piece in
                    Button(intent: MG2TogglePieceIntent(jogakID: piece.jogakID)) {
                        HStack(spacing: 8) {
                            let colors = MG2WidgetStyle.moak(for: piece.color)
                            ZStack {
                                if piece.isDone {
                                    Circle().fill(colors.deep)
                                    Image(systemName: "checkmark").font(.system(size: 9, weight: .heavy)).foregroundStyle(.white)
                                } else {
                                    Circle().strokeBorder(colors.base, lineWidth: 2)
                                }
                            }
                            .frame(width: 20, height: 20)
                            Text(piece.title)
                                .font(.pretendard(13, .semibold, relativeTo: .footnote))
                                .foregroundStyle(piece.isDone ? MG2WidgetStyle.faint : MG2WidgetStyle.ink)
                                .strikethrough(piece.isDone, color: MG2WidgetStyle.faint)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(piece.title + (piece.isDone ? " 완료 취소" : " 완료하기"))
                }
                Spacer(minLength: 0)
            }
        }
    }
}
