//
//  CategoryFilterSheetView.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/01.
//

import UIKit
import SnapKit
import ReusableKit
import Then

class CategoryFilterSheetView: UIViewController {
    
    private var categorySelectedList: [String] = []
    
    var selectedCategoryIndexPath: IndexPath?
    
    enum Reusable {
        static let categoryCell = ReusableCell<CategoryFilterCollectionViewCell>()
    }
    
    // private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    //     let layout = LeftAlignedCollectionViewFlowLayout()
    // }
}
