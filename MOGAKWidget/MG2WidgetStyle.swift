import SwiftUI

// 위젯 확장은 UIKit DS를 쓰지 않으므로 필요한 토큰만 같은 값으로 옮겨 둔다 (MG_Design/DS.swift와 같은 값).
enum MG2WidgetStyle {
    static let accent = Color(hex: 0x4B5EF6)
    static let ink = Color(hex: 0x17182B)
    static let sub = Color(hex: 0x5E6178)
    static let muted = Color(hex: 0x6B6E85)
    /// 다이나믹 아일랜드(검정) 위 보조 글자 (`island-sub`).
    static let islandSub = Color(hex: 0xA8ABBE)
    static let faint = Color(hex: 0x8A8DA3)
    static let canvas = Color(hex: 0xF2F3F9)
    static let surface = Color.white
    static let track = Color(hex: 0xE3E4EE)

    /// 서버 모각 색(DesignSystemPalette.mogakColors 순서) → (base 테두리, deep 채움 · 체크)
    private static let serverMogakColors = ["475FFD", "FF4C77", "F98A08", "11D796", "FF6827", "9C31FF", "21CAFF", "FF2F2F"]
    private static let moak: [(base: UInt32, deep: UInt32)] = [
        (0x4B5EF6, 0x4B5EF6), (0xEF5B7E, 0xD63A64), (0xF0922F, 0xC9650F), (0x4DCB8C, 0x1E9A62),
        (0xF07438, 0xD9531F), (0x9038F0, 0x8030E0), (0x5CC6F7, 0x1386C4), (0xE8473C, 0xD3362C)
    ]

    static func moak(for hex: String?) -> (base: Color, deep: Color) {
        let key = (hex ?? "").uppercased().replacingOccurrences(of: "#", with: "")
        let value = moak[serverMogakColors.firstIndex(of: key) ?? 0]
        return (Color(hex: value.base), Color(hex: value.deep))
    }

    private static let pose: [String: (light: UInt32, deep: UInt32)] = [
        "wave": (0x8FA8F5, 0x3445D6), "peace": (0xF5C842, 0x9A6A00), "wink": (0x7FD39A, 0x1E7A45), "love": (0xF59AB8, 0xB8305A),
        "dizzy": (0xB79AE8, 0x6A3FC4), "hurry": (0xF5A54A, 0xB85C00), "think": (0x6FD1C0, 0x18806F), "thumbs": (0xF07A6A, 0xB33A2C),
        "tired": (0xD9AE85, 0x8A5A2E), "fighting": (0xB8DB5A, 0x4E7A12), "sweat": (0x7E9CF0, 0x2F55C8), "proud": (0xB28AF0, 0x6A3FC4)
    ]

    static func poseLight(_ name: String) -> Color { Color(hex: pose[name]?.light ?? 0x8FA8F5) }
    static func poseDeep(_ name: String) -> Color { Color(hex: pose[name]?.deep ?? 0x3445D6) }

    /// 모각이 일러스트(자르지 않고 맞춤). 장식이라 VoiceOver에서 뺀다. 크기는 부르는 쪽에서 frame으로.
    static func poseImage(_ name: String) -> some View {
        Image("moak.\(name)").resizable().scaledToFit().accessibilityHidden(true)
    }
}

extension Font {
    /// Pretendard (Shared/Fonts, 위젯 확장 Info.plist UIAppFonts에 등록).
    static func pretendard(_ size: CGFloat, _ weight: Font.Weight, relativeTo style: Font.TextStyle) -> Font {
        let name: String
        switch weight {
        case .regular: name = "Pretendard-Regular"
        case .medium: name = "Pretendard-Medium"
        case .semibold: name = "Pretendard-SemiBold"
        case .bold: name = "Pretendard-Bold"
        default: name = "Pretendard-ExtraBold"
        }
        return .custom(name, size: size, relativeTo: style)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

extension MG2TodaySnapshot {
    /// 그날의 요약. 오늘 요약이 지난 날 것이면 앱이 미리 둔 내일 요약을 쓴다.
    static func load(for day: Date) -> MG2TodaySnapshot? {
        let defaults = UserDefaults(suiteName: MG2AppGroup.identifier)
        return [MG2AppGroup.snapshotKey, MG2AppGroup.nextDaySnapshotKey]
            .compactMap { defaults?.data(forKey: $0).flatMap { try? JSONDecoder().decode(MG2TodaySnapshot.self, from: $0) } }
            .first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
}
