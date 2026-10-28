import AppIntents
import Foundation

/// 위젯 · 라이브 액티비티 버튼이 부르는 일. LiveActivityIntent는 앱 프로세스에서 실행되므로
/// 앱이 실행 시 handler를 채우고, 위젯 확장 쪽 복사본은 비어 있다.
enum MG2PieceIntentBridge {
    nonisolated(unsafe) static var completeNext: (() async throws -> Void)?
    nonisolated(unsafe) static var toggle: ((Int) async throws -> Void)?
}

struct MG2CompleteNextPieceIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "다음 조각 완료"

    func perform() async throws -> some IntentResult {
        try await MG2PieceIntentBridge.completeNext?()
        return .result()
    }
}

struct MG2TogglePieceIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "조각 체크"

    @Parameter(title: "조각")
    var jogakID: Int

    init() {}

    init(jogakID: Int) {
        self.jogakID = jogakID
    }

    func perform() async throws -> some IntentResult {
        try await MG2PieceIntentBridge.toggle?(jogakID)
        return .result()
    }
}
