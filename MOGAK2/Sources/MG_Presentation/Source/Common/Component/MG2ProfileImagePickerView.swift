import UIKit
import SnapKit

/// 기본 프로필 이미지를 고르는 가로 목록. 회원가입과 프로필 수정 화면이 함께 쓴다.
final class MG2ProfileImagePickerView: UIView {
    static let height: CGFloat = 56

    var onSelection: ((Int) -> Void)?

    private let imageIDs: [Int]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Self.height, height: Self.height)
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(MG2ProfileImageCell.self, forCellWithReuseIdentifier: MG2ProfileImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init(imageIDs: [Int]) {
        self.imageIDs = imageIDs
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectImage(at index: Int) {
        guard imageIDs.indices.contains(index) else { return }
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
    }
}

extension MG2ProfileImagePickerView: UICollectionViewDataSource, UICollectionViewDelegate {
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
