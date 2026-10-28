import Foundation

/// 81칸의 한 칸.
struct MG2FullBoardCell {
    enum Kind {
        case goal, mogak, jogak, empty
    }

    let kind: Kind
    var title = ""
    var colorHex: String?
}

/// 모다라트 81칸 전체 보기. 가운데 블록은 최종 목표 + 모각 8개, 바깥 블록은 모각 + 조각 8개.
@MainActor
final class MG2FullBoardViewModel {
    let modalartTitle: String

    private let useCase: ModalartUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let mogaks: [MG2ModalartMogakItemEntity]
    private let isGuest: Bool
    private var jogakTitlesByMogakID = [Int: [String]]()
    /// 조각 제목을 불러오는 중. 이때 모각이 있는 블록의 둘레 8칸은 제목 없는 조각 칸(스켈레톤 자리)이다.
    private var isLoadingJogaks = false

    init(useCase: ModalartUseCase, adPolicyUseCase: AdPolicyUseCase, modalartTitle: String, mogaks: [MG2ModalartMogakItemEntity], isGuest: Bool) {
        self.useCase = useCase
        self.adPolicyUseCase = adPolicyUseCase
        self.modalartTitle = modalartTitle
        self.mogaks = mogaks
        self.isGuest = isGuest
    }

    /// 9블록 × 9칸, 둘 다 판과 같은 순서(가운데가 4번).
    var blocks: [[MG2FullBoardCell]] {
        (0..<MG2MandalaGrid.itemCount).map { blockIndex in
            guard let mogakIndex = MG2MandalaGrid.contentIndex(for: blockIndex) else { return centerBlock }
            guard mogaks.indices.contains(mogakIndex) else { return Array(repeating: MG2FullBoardCell(kind: .empty), count: MG2MandalaGrid.itemCount) }
            return block(for: mogaks[mogakIndex])
        }
    }

    /// 누른 칸의 모각. 가운데 블록은 둘레 칸, 바깥 블록은 칸 전체가 그 모각이다. 최종 목표 · 빈 모각 자리는 nil.
    func mogak(atBlock blockIndex: Int, cell cellIndex: Int) -> MG2ModalartMogakItemEntity? {
        let mogakIndex = blockIndex == MG2MandalaGrid.centerIndex ? MG2MandalaGrid.contentIndex(for: cellIndex) : MG2MandalaGrid.contentIndex(for: blockIndex)
        guard let mogakIndex, mogaks.indices.contains(mogakIndex) else { return nil }
        return mogaks[mogakIndex]
    }

    /// 81칸을 닫을 때가 전면 광고 자리다.
    var canShowInterstitial: Bool { adPolicyUseCase.canShowInterstitial }

    func didShowInterstitial() {
        adPolicyUseCase.didShowInterstitial()
    }

    /// 둘러보기 판은 서버에 조각이 없으니 모각까지만 보여 준다.
    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isGuest, !mogaks.isEmpty else {
            completion(.success(()))
            return
        }
        isLoadingJogaks = true
        Task {
            do {
                jogakTitlesByMogakID = try await useCase.loadJogakTitles(for: mogaks, from: Date())
                isLoadingJogaks = false
                completion(.success(()))
            } catch {
                isLoadingJogaks = false
                completion(.failure(error))
            }
        }
    }

    private var centerBlock: [MG2FullBoardCell] {
        (0..<MG2MandalaGrid.itemCount).map { index in
            guard let mogakIndex = MG2MandalaGrid.contentIndex(for: index) else { return MG2FullBoardCell(kind: .goal, title: modalartTitle) }
            guard mogaks.indices.contains(mogakIndex) else { return MG2FullBoardCell(kind: .empty) }
            return MG2FullBoardCell(kind: .mogak, title: mogaks[mogakIndex].title, colorHex: mogaks[mogakIndex].color)
        }
    }

    private func block(for mogak: MG2ModalartMogakItemEntity) -> [MG2FullBoardCell] {
        let titles = jogakTitlesByMogakID[mogak.mogakId] ?? []
        return (0..<MG2MandalaGrid.itemCount).map { index in
            guard let jogakIndex = MG2MandalaGrid.contentIndex(for: index) else { return MG2FullBoardCell(kind: .mogak, title: mogak.title, colorHex: mogak.color) }
            guard !isLoadingJogaks else { return MG2FullBoardCell(kind: .jogak) }
            guard titles.indices.contains(jogakIndex) else { return MG2FullBoardCell(kind: .empty) }
            return MG2FullBoardCell(kind: .jogak, title: titles[jogakIndex], colorHex: mogak.color)
        }
    }
}
