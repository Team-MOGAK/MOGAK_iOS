//
//  ModalartMainViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import Foundation
import UIKit
import SnapKit

//MARK: - 모다라트 화면
class ModalartMainViewController: UIViewController {
    
    private lazy var modalArtCollectionView: UICollectionView = {
        let collectionView = UICollectionView()
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createFlowlayout() -> UICollectionViewFlowLayout {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.minimumLineSpacing = 10
        flowlayout.minimumInteritemSpacing = 10
        let threePicture: CGFloat = modalArtCollectionView.frame.width / 3.0
        
        return flowlayout
    }
}
