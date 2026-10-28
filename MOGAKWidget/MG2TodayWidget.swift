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
        completion(MG2TodayEntry(date: Date(), snapshot: .loadForToday()))
    }

    /// 자정에 새 날 조각으로 바뀐다 (앱이 열리기 전까지는 빈 상태).
    func getTimeline(in context: Context, completion: @escaping (Timeline<MG2TodayEntry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
        completion(Timeline(entries: [MG2TodayEntry(date: Date(), snapshot: .loadForToday())], policy: .after(midnight)))
    }
}

struct MG2TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MG2TodayWidget", provider: MG2TodayProvider()) { entry in
            MG2TodayWidgetView(entry: entry)
                .containerBackground(MG2WidgetStyle.surface, for: .widget)
        }
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
            family == .systemSmall ? AnyView(MiniBoard(snapshot: snapshot)) : AnyView(TodayList(snapshot: snapshot))
        } else {
            VStack(spacing: 6) {
                Image(MG2WidgetStyle.poseImage("wave")).resizable().scaledToFit().frame(width: 56, height: 56)
                Text("앱을 열어 오늘의 조각을 불러와요")
                    .font(.pretendard(13, .medium, relativeTo: .footnote))
                    .foregroundStyle(MG2WidgetStyle.sub)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

/// 소형: 미니 판. 가운데는 오늘 n/m, 둘레는 모각별 오늘 진척.
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

    var body: some View {
        let cells = mogaks
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(0..<3, id: \.self) { row in
                GridRow {
                    ForEach(0..<3, id: \.self) { column in
                        cell(at: row * 3 + column, cells: cells)
                    }
                }
            }
        }
        .accessibilityLabel("오늘의 조각 \(snapshot.done) / \(snapshot.total)")
    }

    @ViewBuilder
    private func cell(at index: Int, cells: [(title: String, color: String?, ratio: Double)]) -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        if index == 4 {
            shape.fill(MG2WidgetStyle.accent)
                .overlay(Text("\(snapshot.done)/\(snapshot.total)").font(.pretendard(12, .heavy, relativeTo: .caption)).monospacedDigit().foregroundStyle(.white))
        } else {
            let mogakIndex = index < 4 ? index : index - 1
            if cells.indices.contains(mogakIndex) {
                let colors = MG2WidgetStyle.moak(for: cells[mogakIndex].color)
                shape.fill(MG2WidgetStyle.canvas)
                    .overlay(alignment: .bottom) {
                        GeometryReader { proxy in
                            Rectangle().fill(colors.bg).frame(height: proxy.size.height * cells[mogakIndex].ratio).frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .clipShape(shape)
                    .overlay(Circle().fill(colors.deep).frame(width: 6, height: 6))
            } else {
                shape.fill(MG2WidgetStyle.canvas)
            }
        }
    }
}

/// 중형: 오늘 n/m + 모각이 + 조각 체크 4줄.
private struct TodayList: View {
    let snapshot: MG2TodaySnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("오늘의 조각").font(.pretendard(12, .bold, relativeTo: .caption)).foregroundStyle(MG2WidgetStyle.sub)
                Text("\(snapshot.done) / \(snapshot.total)").font(.pretendard(22, .heavy, relativeTo: .title2)).monospacedDigit().foregroundStyle(MG2WidgetStyle.poseDeep(snapshot.pose))
                    .contentTransition(.numericText())
                Spacer(minLength: 0)
                Image(MG2WidgetStyle.poseImage(snapshot.pose)).resizable().scaledToFit().frame(width: 52, height: 52)
            }
            .frame(width: 96, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(snapshot.pieces.prefix(4).enumerated()), id: \.offset) { _, piece in
                    Button(intent: MG2TogglePieceIntent(jogakID: piece.jogakID)) {
                        HStack(spacing: 8) {
                            let colors = MG2WidgetStyle.moak(for: piece.color)
                            ZStack {
                                Circle().strokeBorder(piece.isDone ? colors.deep : MG2WidgetStyle.border, lineWidth: 2)
                                if piece.isDone {
                                    Circle().fill(colors.deep)
                                    Image(systemName: "checkmark").font(.system(size: 9, weight: .heavy)).foregroundStyle(.white)
                                }
                            }
                            .frame(width: 20, height: 20)
                            Text(piece.title)
                                .font(.pretendard(13, .semibold, relativeTo: .footnote))
                                .foregroundStyle(piece.isDone ? MG2WidgetStyle.faint : MG2WidgetStyle.ink)
                                .strikethrough(piece.isDone, color: MG2WidgetStyle.faint)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(piece.title + (piece.isDone ? " 완료 취소" : " 완료하기"))
                }
                Spacer(minLength: 0)
            }
        }
    }
}
