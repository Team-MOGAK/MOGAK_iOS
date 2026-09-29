import SnapKit
import UIKit

/// 기본 프로필 이미지 중 하나를 고르는 바텀 시트. 고른 순서를 onSelection으로 알려준다.
final class MG2ProfileImageSelectModal: UIViewController {
    private static let columnCount = 4
    private static let itemSide: CGFloat = 64
    private static let lineSpacing: CGFloat = 20
    private static let titleTop: CGFloat = 49
    private static let titleHeight: CGFloat = 28
    private static let gridTop: CGFloat = 24
    private static let bottomInset: CGFloat = 24

    var onSelection: ((Int) -> Void)?

    private let imageIDs: [Int]
    private let selectedIndex: Int?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 이미지 선택"
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = DesignSystemColor.black.value
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Self.itemSide, height: Self.itemSide)
        layout.minimumLineSpacing = Self.lineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.register(MG2ProfileImageCell.self, forCellWithReuseIdentifier: MG2ProfileImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    /// 시트 높이. 제목과 이미지 줄 수로 정해진다.
    var preferredHeight: CGFloat {
        Self.titleTop + Self.titleHeight + Self.gridTop + gridHeight + Self.bottomInset
    }

    private var gridHeight: CGFloat {
        let rowCount = CGFloat((imageIDs.count + Self.columnCount - 1) / Self.columnCount)
        return rowCount * Self.itemSide + max(rowCount - 1, 0) * Self.lineSpacing
    }

    init(imageIDs: [Int], selectedIndex: Int?) {
        self.imageIDs = imageIDs
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLayout()
        if let selectedIndex {
            collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: [])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 화면 폭과 상관없이 한 줄에 4개씩 놓는다.
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let columnCount = CGFloat(Self.columnCount)
        layout.minimumInteritemSpacing = floor((collectionView.bounds.width - Self.itemSide * columnCount) / (columnCount - 1))
    }

    private func configureLayout() {
        view.addSubviews(titleLabel, collectionView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Self.titleTop)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(Self.titleHeight)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Self.gridTop)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(gridHeight)
        }
    }
}

extension MG2ProfileImageSelectModal: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageIDs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2ProfileImageCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2ProfileImageCell else { return reusableCell }
        cell.configure(imageName: MG2ProfileImage.assetName(for: imageIDs[indexPath.item]))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelection?(indexPath.item)
    }
}
