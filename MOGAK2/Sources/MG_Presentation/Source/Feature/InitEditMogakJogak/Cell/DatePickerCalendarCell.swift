//
//  DatePickerCalendarCell.swift
//  MOGAK
//
//  Created by 이재혁 on 12/8/23.
//

import Foundation
import UIKit
import FSCalendar

//enum SelectionType : Int {
//    case none
//    case single
//    case leftBorder
//    case middle
//    case rightBorder
//}

//enum SelectionType {
//    case none
//    case today
//    case single
//    case leftBorder
//    case middle
//    case rightBorder
//}

class DatePickerCalendarCell: FSCalendarCell {
    
//    weak var selectionLayer: CAShapeLayer!
//    
//    var selectionType: SelectionType = .none {
//        didSet {
//            setNeedsLayout()
//        }
//    }
//    
//    required init!(coder aDecoder: NSCoder!) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        let selectionLayer = CAShapeLayer()
//        selectionLayer.fillColor = UIColor.black.cgColor
//        selectionLayer.actions = ["hidden": NSNull()]
//        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
//        self.selectionLayer = selectionLayer
//        
//        self.shapeLayer.isHidden = true
//        
//        let view = UIView(frame: self.bounds)
//        view.backgroundColor = .white
//        self.backgroundView = view
//        backgroundColor = .white
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.backgroundView?.frame = self.bounds.insetBy(dx: 0, dy: 0)
//        self.selectionLayer.frame = self.contentView.bounds
//        
//        var titleFrame = titleLabel.frame
//        titleFrame.origin.y += 3
//        titleLabel.frame = titleFrame
//        
//        self.selectionLayer.isHidden = false
//        if selectionType == .middle {
//            self.selectionLayer.path = UIBezierPath(rect: self.selectionLayer.bounds).cgPath
//            //self.selectionLayer.fillColor = Colors.date_picker_middle_day_bg.cgColor
//            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
//        }
//        else if selectionType == .leftBorder {
//            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
//            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
//            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
//        }
//        else if selectionType == .rightBorder {
//            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
//            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
//            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
//        }
//        else if selectionType == .single {
//            let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
//            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
//            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
//            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
//        } else {
//            self.selectionLayer.isHidden = true
//        }
//    }
    
    private weak var circleImageView: UIImageView?
    private weak var selectionLayer: CAShapeLayer?
    private weak var roundedLayer: CAShapeLayer?
    private weak var todayLayer: CAShapeLayer?
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.lightGray.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel?.layer)
        self.selectionLayer = selectionLayer
        
        let roundedLayer = CAShapeLayer()
        roundedLayer.fillColor = UIColor.blue.cgColor
        roundedLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(roundedLayer, below: self.titleLabel?.layer)
        self.roundedLayer = roundedLayer
        
        let todayLayer = CAShapeLayer()
        todayLayer.fillColor = UIColor.clear.cgColor
        todayLayer.strokeColor = UIColor.orange.cgColor
        todayLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(todayLayer, below: self.titleLabel?.layer)
        self.todayLayer = todayLayer
        
        self.shapeLayer.isHidden = true
        let view = UIView(frame: self.bounds)
        self.backgroundView = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectionLayer?.frame = self.contentView.bounds
        self.roundedLayer?.frame = self.contentView.bounds
        self.todayLayer?.frame = self.contentView.bounds
        
        let contentHeight = self.contentView.frame.height
        let contentWidth = self.contentView.frame.width
        
        let selectionLayerBounds = selectionLayer?.bounds ?? .zero
        let selectionLayerWidth = selectionLayer?.bounds.width ?? .zero
        let roundedLayerHeight = roundedLayer?.frame.height ?? .zero
        let roundedLayerWidth = roundedLayer?.frame.width ?? .zero
        
        switch selectionType {
        case .middle:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = true
            
            let selectionRect = selectionLayerBounds
                .insetBy(dx: 0.0, dy: 4.0)
            self.selectionLayer?.path = UIBezierPath(rect: selectionRect).cgPath
            
        case .leftBorder:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            let selectionRect = selectionLayerBounds
                .insetBy(dx: selectionLayerWidth / 4, dy: 4)
                .offsetBy(dx: selectionLayerWidth / 4, dy: 0.0)
            self.selectionLayer?.path = UIBezierPath(rect: selectionRect).cgPath
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .rightBorder:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            let selectionRect = selectionLayerBounds
                .insetBy(dx: selectionLayerWidth / 4, dy: 4)
                .offsetBy(dx: -selectionLayerWidth / 4, dy: 0.0)
            self.selectionLayer?.path = UIBezierPath(rect: selectionRect).cgPath
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .single:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .today:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = false
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.todayLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .none:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = true
        }
    }
    
}
