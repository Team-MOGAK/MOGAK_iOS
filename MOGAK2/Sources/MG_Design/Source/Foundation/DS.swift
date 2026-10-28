import UIKit

// 모다라트 디자인 시스템 토큰 (tokens.json v1). 라이트 테마 하나.
enum DS {
    enum Color {
        static let accent = UIColor(hex: "4B5EF6")
        static let accentDeep = UIColor(hex: "3445D6")
        static let accentSoft = UIColor(hex: "E8EBFF")
        static let accentTint = UIColor(hex: "F4F5FF")
        static let accentLine = UIColor(hex: "C9CFFC")
        static let accentDash = UIColor(hex: "8E9AF7")

        static let ink = UIColor(hex: "17182B")
        static let ink2 = UIColor(hex: "2B2C40")
        static let ink3 = UIColor(hex: "4B4E66")
        static let sub = UIColor(hex: "5E6178")
        static let muted = UIColor(hex: "6B6E85")
        // faint · placeholder · ghost는 4.5:1 미만. 장식·완료 상태에만.
        static let faint = UIColor(hex: "8A8DA3")
        static let placeholder = UIColor(hex: "9A9CB2")
        static let ghost = UIColor(hex: "A3A5BA")

        static let canvas = UIColor(hex: "F2F3F9")
        static let surface = UIColor(hex: "FFFFFF")
        static let fill = UIColor(hex: "F1F2F7")
        static let segment = UIColor(hex: "EEEFF5")
        static let track = UIColor(hex: "E3E4EE")
        static let line = UIColor(hex: "ECEDF3")
        static let border = UIColor(hex: "D3D5E3")
        static let disabled = UIColor(hex: "C3C6D6")
        static let doneRow = UIColor(hex: "F7F8FC")
        static let tabActive = UIColor(hex: "ECEDF4")
        static let listTile = UIColor(hex: "F6F6FA")

        static let success = UIColor(hex: "11C784")
        static let successDeep = UIColor(hex: "0F7A4E")
        static let successBg = UIColor(hex: "E0F8EE")
        static let danger = UIColor(hex: "D92D20")

        static let toast = UIColor(hex: "17182B")
        static let toastSub = UIColor(hex: "C9CAE0")
        static let scrim = UIColor(hex: "17182B").withAlphaComponent(0.38)

        static let green0 = UIColor(hex: "EEF9F3")
        static let green1 = UIColor(hex: "63D598")
        static let green2 = UIColor(hex: "C5F1DF")

        static let island = UIColor(hex: "000000")
        static let islandSub = UIColor(hex: "A8ABBE")
        static let lockSurface = UIColor.white.withAlphaComponent(0.94)
        static let adDark = UIColor(hex: "0E0F1A")
        static let avatarBg = UIColor(hex: "EEEFF7")
        static let wall1 = UIColor(hex: "3B4BD8")
        static let wall2 = UIColor(hex: "7E6CF0")
        static let wall3 = UIColor(hex: "F1A7C9")
    }

    // 모각 색 8개 × 네 단계. base 테두리·점, deep 채움·체크, bg 태그 바탕·칸 채움, fg 태그 글자·%.
    enum Moak: Int, CaseIterable {
        case blue, pink, orange, green, coral, purple, sky, red

        var base: UIColor { UIColor(hex: Self.values[rawValue].0) }
        var deep: UIColor { UIColor(hex: Self.values[rawValue].1) }
        var bg: UIColor { UIColor(hex: Self.values[rawValue].2) }
        var fg: UIColor { UIColor(hex: Self.values[rawValue].3) }

        private static let values = [
            ("4B5EF6", "4B5EF6", "E8EBFF", "3445D6"),
            ("EF5B7E", "D63A64", "FFE6EC", "B8305A"),
            ("F0922F", "C9650F", "FFF0DF", "9E530A"),
            ("4DCB8C", "1E9A62", "DDF7EA", "17784D"),
            ("F07438", "D9531F", "FFE9DF", "AC4318"),
            ("9038F0", "8030E0", "F1E6FF", "6A21C4"),
            ("5CC6F7", "1386C4", "DDF3FF", "116E9E"),
            ("E8473C", "D3362C", "FFE5E3", "B02A23")
        ]

        // 서버에 저장된 모각 색(DesignSystemPalette.mogakColors 순서와 같음)을 모각 색으로. 모르는 값은 blue.
        static func from(hex: String?) -> Moak {
            let key = (hex ?? "").uppercased().replacingOccurrences(of: "#", with: "")
            return DesignSystemPalette.mogakColors.firstIndex(of: key).flatMap(Moak.init(rawValue:)) ?? .blue
        }

        /// 서버 색을 화면 색으로. 모각 팔레트에 있으면 모각 색(base), 기본 회색은 `disabled`, 나머지는 그대로.
        static func displayColor(forServerHex hex: String) -> UIColor {
            let key = hex.uppercased().replacingOccurrences(of: "#", with: "")
            if key == DesignSystemPalette.neutralGrayHex { return DS.Color.disabled }
            if let index = DesignSystemPalette.mogakColors.firstIndex(of: key), let moak = Moak(rawValue: index) { return moak.base }
            return UIColor(hex: key)
        }
    }

    // 모각이 포즈와 짝이 되는 색. light는 다이나믹 아일랜드, deep은 흰 바탕.
    enum Pose: String, CaseIterable {
        case wave, wink, peace, thumbs, fighting, proud, love, dizzy, hurry, think, sweat, tired

        var light: UIColor { UIColor(hex: Self.values[self]!.0) }
        var deep: UIColor { UIColor(hex: Self.values[self]!.1) }
        var imageName: String { "moak.\(rawValue)" }

        private static let values: [Pose: (String, String)] = [
            .wave: ("8FA8F5", "3445D6"), .peace: ("F5C842", "9A6A00"), .wink: ("7FD39A", "1E7A45"),
            .love: ("F59AB8", "B8305A"), .dizzy: ("B79AE8", "6A3FC4"), .hurry: ("F5A54A", "B85C00"),
            .think: ("6FD1C0", "18806F"), .thumbs: ("F07A6A", "B33A2C"), .tired: ("D9AE85", "8A5A2E"),
            .fighting: ("B8DB5A", "4E7A12"), .sweat: ("7E9CF0", "2F55C8"), .proud: ("B28AF0", "6A3FC4")
        ]
    }

    enum Space {
        static let gutter: CGFloat = 16
        static let cellGap: CGFloat = 10
        static let stack: CGFloat = 10
        static let sheet: CGFloat = 20
        static let cardX: CGFloat = 18
        static let tabBottom: CGFloat = 12
    }

    // layer.cornerCurve = .continuous 와 함께 씁니다.
    enum Radius {
        static let cell: CGFloat = 22
        static let card: CGFloat = 22
        static let row: CGFloat = 20
        static let button: CGFloat = 16
        static let field: CGFloat = 14
        static let sheet: CGFloat = 30
        static let tag: CGFloat = 8
        static let island: CGFloat = 44
        static let lock: CGFloat = 24
    }

    enum Size {
        static let button: CGFloat = 52
        static let touch: CGFloat = 44
        static let chip: CGFloat = 36
        static let check: CGFloat = 28
        static let tabBar: CGFloat = 64
        static let row: CGFloat = 56
    }

    struct Shadow {
        let color: UIColor
        let opacity: Float
        let y: CGFloat
        let blur: CGFloat

        static let card = Shadow(color: UIColor(hex: "1E2050"), opacity: 0.06, y: 2, blur: 5)
        static let tabBar = Shadow(color: UIColor(hex: "1E2050"), opacity: 0.12, y: 10, blur: 15)
        static let toast = Shadow(color: UIColor(hex: "17182B"), opacity: 0.3, y: 12, blur: 15)
        static let goal = Shadow(color: UIColor(hex: "4B5EF6"), opacity: 0.32, y: 10, blur: 12)
    }
}

extension CALayer {
    func apply(_ shadow: DS.Shadow) {
        shadowColor = shadow.color.cgColor
        shadowOpacity = shadow.opacity
        shadowOffset = CGSize(width: 0, height: shadow.y)
        shadowRadius = shadow.blur / 2
    }
}

// 글자 스타일. Pretendard + Dynamic Type(accessibility1까지), 자간 −0.02em.
enum T: CaseIterable {
    case title1, onboardingTitle, metric, title2
    case headline, button, body, row, callout, settingRow, subhead, paragraph
    case footnoteBold, footnote, footnoteHeavy, caption1, caption1Semi, caption2

    private var spec: (size: CGFloat, lineHeight: CGFloat, weight: UIFont.Pretendard, textStyle: UIFont.TextStyle) {
        switch self {
        case .title1: return (28, 34, .extraBold, .largeTitle)
        case .onboardingTitle: return (26, 34, .extraBold, .title1)
        case .metric: return (22, 26, .extraBold, .title2)
        case .title2: return (20, 25, .extraBold, .title3)
        case .headline: return (17, 22, .extraBold, .headline)
        case .button: return (17, 22, .bold, .body)
        case .body: return (17, 22, .semiBold, .body)
        case .row: return (17, 22, .medium, .body)
        case .callout: return (16, 21, .semiBold, .callout)
        case .settingRow: return (16, 21, .medium, .callout)
        case .subhead: return (15, 20, .bold, .subheadline)
        case .paragraph: return (15, 22, .medium, .subheadline)
        case .footnoteBold: return (13, 18, .bold, .footnote)
        case .footnote: return (13, 18, .medium, .footnote)
        case .footnoteHeavy: return (13, 18, .extraBold, .footnote)
        case .caption1: return (12, 16, .bold, .caption1)
        case .caption1Semi: return (12, 16, .semiBold, .caption1)
        case .caption2: return (11, 13, .bold, .caption2)
        }
    }

    var font: UIFont {
        .scaledCapped(.pretendard(spec.weight, size: spec.size), relativeTo: spec.textStyle)
    }

    /// 글자와 같은 비율로 커지고, 글자처럼 accessibility1에서 멈춘다.
    var lineHeight: CGFloat { spec.lineHeight * font.pointSize / spec.size }
    var kern: CGFloat { -0.02 * font.pointSize }

    func attributes(color: UIColor = DS.Color.ink, alignment: NSTextAlignment = .natural) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        paragraph.alignment = alignment
        return [.font: font, .foregroundColor: color, .kern: kern, .paragraphStyle: paragraph]
    }
}

extension UIFont {
    /// 글자 크기 설정(Dynamic Type)을 따르되 accessibility1(accessibilityMedium)까지만 커진다. T에 없는 크기도 이걸로.
    /// 조절 전 폰트(.pretendard)만 넣는다. T.font처럼 이미 조절된 폰트를 넣으면 UIKit이 예외를 던진다.
    static func scaledCapped(_ font: UIFont, relativeTo textStyle: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let maxSize = metrics.scaledValue(for: font.pointSize, compatibleWith: UITraitCollection(preferredContentSizeCategory: .accessibilityMedium))
        return metrics.scaledFont(for: font, maximumPointSize: maxSize)
    }

    /// 숫자가 바뀌는 자리(%, 3/5)는 고정폭 숫자.
    func withMonospacedDigits() -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.featureSettings: [[UIFontDescriptor.FeatureKey.type: kNumberSpacingType, UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector]]])
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension UILabel {
    func apply(_ style: T, color: UIColor = DS.Color.ink) {
        font = style.font
        textColor = color
        adjustsFontForContentSizeCategory = true
    }
}
