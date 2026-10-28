import SnapKit
import UIKit

/// 모다라트 81칸 전체 보기. 칸이 작아서 두 손가락으로 키워 볼 수 있다.
final class MG2FullBoardViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?

    private static let blockGap: CGFloat = 6
    private static let cellGap: CGFloat = 2

    private let viewModel: MG2FullBoardViewModel
    private lazy var headerView = MG2SheetHeaderView(title: "‘\(viewModel.modalartTitle)’ 81칸")
    private let scrollView = UIScrollView()
    private let boardView = UIView()
    private var cellLabels = [[MG2PaddingLabel]]()

    init(viewModel: MG2FullBoardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.canvas
        configureLayout()
        render()
        load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutBoard()
    }

    private func configureLayout() {
        headerView.onClose = { [weak self] in self?.close() }
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubviews(headerView, scrollView)
        scrollView.addSubview(boardView)
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        cellLabels = (0..<MG2MandalaGrid.itemCount).map { _ in
            (0..<MG2MandalaGrid.itemCount).map { _ in
                let label = MG2PaddingLabel(top: 2, bottom: 2, left: 2, right: 2)
                label.textAlignment = .center
                label.numberOfLines = 3
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.6
                label.lineBreakMode = .byTruncatingTail
                label.clipsToBounds = true
                label.layer.cornerRadius = 6
                label.layer.cornerCurve = .continuous
                label.isAccessibilityElement = true
                boardView.addSubview(label)
                return label
            }
        }
    }

    /// 정사각 판을 화면 가운데에. 넓은 화면(Duo 펼침)에서도 560pt까지만.
    private func layoutBoard() {
        let bounds = scrollView.bounds
        guard bounds.width > 0, scrollView.zoomScale == 1 else { return }
        let side = min(bounds.width - DS.Space.gutter * 2, bounds.height - DS.Space.gutter, MG2MandalaGrid.maxBoardWidth)
        boardView.frame = CGRect(x: 0, y: 0, width: side, height: side)
        scrollView.contentSize = boardView.frame.size
        centerBoard()

        let blockSide = (side - Self.blockGap * 2) / 3
        let cellSide = (blockSide - Self.cellGap * 2) / 3
        for (blockIndex, labels) in cellLabels.enumerated() {
            let blockOrigin = CGPoint(x: CGFloat(blockIndex % 3) * (blockSide + Self.blockGap), y: CGFloat(blockIndex / 3) * (blockSide + Self.blockGap))
            for (cellIndex, label) in labels.enumerated() {
                label.frame = CGRect(x: blockOrigin.x + CGFloat(cellIndex % 3) * (cellSide + Self.cellGap), y: blockOrigin.y + CGFloat(cellIndex / 3) * (cellSide + Self.cellGap), width: cellSide, height: cellSide)
            }
        }
    }

    /// 판이 화면보다 작을 때는 가운데에 둔다.
    private func centerBoard() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }

    private func render() {
        for (blocks, labels) in zip(viewModel.blocks, cellLabels) {
            for (cell, label) in zip(blocks, labels) {
                configure(label, with: cell)
            }
        }
    }

    private func configure(_ label: MG2PaddingLabel, with cell: MG2FullBoardCell) {
        let moak = DS.Moak.from(hex: cell.colorHex)
        label.text = cell.title
        switch cell.kind {
        case .goal:
            label.font = .pretendard(.extraBold, size: 12)
            label.textColor = DS.Color.surface
            label.backgroundColor = DS.Color.accent
            label.accessibilityLabel = "최종 목표, \(cell.title)"
        case .mogak:
            label.font = .pretendard(.bold, size: 11)
            label.textColor = moak.fg
            label.backgroundColor = moak.bg
            label.accessibilityLabel = "모각, \(cell.title)"
        case .jogak:
            // 가장 작은 글자는 11pt(caption2). 칸을 넘치면 minimumScaleFactor로 줄어든다.
            label.font = .pretendard(.semiBold, size: 11)
            label.textColor = DS.Color.ink
            label.backgroundColor = DS.Color.surface
            label.accessibilityLabel = "조각, \(cell.title)"
        case .empty:
            label.backgroundColor = DS.Color.segment
            label.accessibilityLabel = "빈 칸"
        }
    }

    private func load() {
        showLoading()
        viewModel.load { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                render()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func close() {
        let viewModel = viewModel
        coordinator?.closeFullBoard(self, showsInterstitial: viewModel.canShowInterstitial) { viewModel.didShowInterstitial() }
    }
}

extension MG2FullBoardViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        boardView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerBoard()
    }
}
