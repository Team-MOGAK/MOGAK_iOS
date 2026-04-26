//
//  CalendarCell.swift
//  MOGAK
//
//  Created by 이재혁 on 12/12/23.
//

import FSCalendar
import UIKit

enum SelectionType {
    case none
    case today
    case single
    case leftBorder
    case middle
    case rightBorder
}

class CalendarCell: FSCalendarCell {

    private weak var circleImageView: UIImageView?
    private weak var selectionLayer: CAShapeLayer?
    private weak var roundedLayer: CAShapeLayer?
    private weak var todayLayer: CAShapeLayer?

    var selectionType: SelectionType = .none {
        didSet {
            print("***********")
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
            self.selectionLayer?.fillColor = UIColor(hex: "000000").cgColor

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
