//
//  DatePickerCalendarCell.swift
//  MOGAK
//
//  Created by 이재혁 on 12/8/23.
//

import Foundation
import UIKit
import FSCalendar

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class DatePickerCalendarCell: FSCalendarCell {
    
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.black.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        self.backgroundView = view
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds.insetBy(dx: 0, dy: 0)
        self.selectionLayer.frame = self.contentView.bounds
        
        var titleFrame = titleLabel.frame
        titleFrame.origin.y += 3
        titleLabel.frame = titleFrame
        
        self.selectionLayer.isHidden = false
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(rect: self.selectionLayer.bounds).cgPath
            //self.selectionLayer.fillColor = Colors.date_picker_middle_day_bg.cgColor
            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
        }
        else if selectionType == .leftBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
        }
        else if selectionType == .rightBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
        }
        else if selectionType == .single {
            let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
            //self.selectionLayer.fillColor = Colors.date_picker_selected_day_bg.cgColor
            self.selectionLayer.fillColor = UIColor(hex: "DDF7FF").cgColor
        } else {
            self.selectionLayer.isHidden = true
        }
    }
    
}
