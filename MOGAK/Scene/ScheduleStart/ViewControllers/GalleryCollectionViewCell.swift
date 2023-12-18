//
//  GallerytableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 10/3/23.
//

import UIKit
import SnapKit

class GalleryCollectionViewCell : UICollectionViewCell {
    
    static let id = "GalleryCollectionViewCell"
    
    
    lazy var grayView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.947, green: 0.953, blue: 0.979, alpha: 1)
        view.layer.cornerRadius = 14
        return view
    }()
    
     lazy var plusView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "plus.circle.fill")
        view.tintColor = UIColor(hex: "#BFC3D4")
        view.layer.cornerRadius = 12
        return view
    }()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    func configureUI(){
        addSubviews(grayView,plusView)
        
        grayView.snp.makeConstraints{
            $0.width.height.equalTo(72)
        }
        plusView.snp.makeConstraints{
            $0.centerX.centerY.equalTo(grayView)
            $0.width.height.equalTo(30)
        }
    }
}
