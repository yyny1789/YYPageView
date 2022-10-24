//
//  UIView+Utils.swift
//  Tou
//
//  Created by aidenluo on 1/26/16.
//  Copyright © 2016 36kr. All rights reserved.
//

import UIKit

extension UIView {
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        } set (value) {
            self.frame = CGRect (x: value, y: self.y, width: self.width, height: self.height)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        } set (value) {
            self.frame = CGRect (x: self.x, y: value, width: self.width, height: self.height)
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: value, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: self.width, height: value)
        }
    }
    
    var left: CGFloat {
        get {
            return self.x
        } set (value) {
            self.x = value
        }
    }
    
    var right: CGFloat {
        get {
            return self.x + self.width
        } set (value) {
            self.x = value - self.width
        }
    }
    
    var top: CGFloat {
        get {
            return self.y
        } set (value) {
            self.y = value
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.y + self.height
        } set (value) {
            self.y = value - self.height
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        } set (value) {
            self.center = CGPoint(x: value, y: self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        } set (value) {
            self.center = CGPoint(x: self.center.x, y: value)
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        } set (value) {
            self.frame = CGRect (origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set (value) {
            self.frame = CGRect (origin: self.frame.origin, size: value)
        }
    }
    
    func leftWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    func rightWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    func topWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    func bottomWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
        
    func setWidth(_ width:CGFloat)
    {
        self.frame.size.width = width
    }
    
    func setHeight(_ height:CGFloat)
    {
        self.frame.size.height = height
    }
    
    func setSize(_ size:CGSize)
    {
        self.frame.size = size
    }
    
    func setOrigin(_ point:CGPoint)
    {
        self.frame.origin = point
    }
    
    func setX(_ x:CGFloat) //only change the origin x
    {
        self.frame.origin = CGPoint(x: x, y: self.frame.origin.y)
    }
    
    func setY(_ y:CGFloat) //only change the origin x
    {
        self.frame.origin = CGPoint(x: self.frame.origin.x, y: y)
    }
    
    func setCenterX(_ x:CGFloat) //only change the origin x
    {
        self.center = CGPoint(x: x, y: self.center.y)
    }
    
    func setCenterY(_ y:CGFloat) //only change the origin x
    {
        self.center = CGPoint(x: self.center.x, y: y)
    }
    
    func roundCorner(_ radius:CGFloat)
    {
        self.layer.cornerRadius = radius
    }
    
    func setTop(_ top:CGFloat)
    {
        self.frame.origin.y = top
    }
    
    func setLeft(_ left:CGFloat)
    {
        self.frame.origin.x = left
    }
    
    func setRight(_ right:CGFloat)
    {
        self.frame.origin.x = right - self.frame.size.width
    }
    
    func setBottom(_ bottom:CGFloat)
    {
        self.frame.origin.y = bottom - self.frame.size.height
    }
}

extension UIView {
    typealias TapResponseClosure = (_ tap: UITapGestureRecognizer) -> Void
    
    fileprivate struct ClosureStorage {
        static var TapClosureStorage: [UITapGestureRecognizer : TapResponseClosure] = [:]
    }
    
    func addSingleTapGestureRecognizerWithResponder(_ responder: @escaping TapResponseClosure) {
        self.addTapGestureRecognizerForNumberOfTaps(responder)
    }
    
    func addTapGestureRecognizerForNumberOfTaps(_ responder: @escaping TapResponseClosure) {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        ClosureStorage.TapClosureStorage[tap] = responder
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let closureForTap = ClosureStorage.TapClosureStorage[sender] {
            closureForTap(sender)
        }
    }
}

extension UIView {
    
    enum Horizontal {
        case left
        case center
        case right
        
        var attribute: NSLayoutConstraint.Attribute {
            switch self {
            case .left:
                return .left
            case .right:
                return .right
            case .center:
                return .centerX
            }
        }
    }
    
    enum Vertical {
        case top
        case center
        case bottom
        
        var attribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top:
                return .top
            case .center:
                return .centerY
            case .bottom:
                return .bottom
            }
        }
    }

    func positionToSuperView(horizontal: Horizontal, hOffset: CGFloat, vertical: Vertical, vOffset: CGFloat) {
        guard let superView = self.superview else {
            assertionFailure("在调用这个方法前要将它加入到父 View 上面")
            return
        }
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: self, attribute: horizontal.attribute, relatedBy: .equal, toItem: superView, attribute: horizontal.attribute, multiplier: 1.0, constant: hOffset))
        constraints.append(NSLayoutConstraint(item: self, attribute: vertical.attribute, relatedBy: .equal, toItem: superView, attribute: vertical.attribute, multiplier: 1.0, constant: vOffset))
        NSLayoutConstraint.activate(constraints)
    }
    
}

extension UIView {
    
    func addCorner(_ roundedRect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func addCorner(byRoundingCorners corners: UIRectCorner = [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    //设置view指定位置指定大小圆角
    func addCorner(topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat){
        if topLeft == 0 && topRight == 0 && bottomRight == 0 && bottomLeft == 0 {
            self.layer.mask = nil
            return
        }
        let maxX = self.bounds.maxX
        let maxY = self.bounds.maxY
        //获取中心点
        let topLeftCenter = CGPoint.init(x: topLeft, y: topLeft)
        let topRightCener = CGPoint.init(x: maxX - topRight, y: topRight)
        let bottomRightCenter = CGPoint.init(x: maxX - bottomRight, y: maxY - bottomRight)
        let bottomLeftCenter = CGPoint.init(x: bottomLeft, y: maxY - bottomLeft)
        let shaperLayer = CAShapeLayer.init()
        let mutablePath = CGMutablePath.init()
        //左上
        mutablePath.addArc(center: topLeftCenter, radius: topLeft, startAngle: .pi, endAngle: .pi / 2 * 3, clockwise: false)
        //右上
        mutablePath.addArc(center: topRightCener, radius: topRight, startAngle: .pi / 2 * 3, endAngle:0, clockwise: false)
        //右下
        mutablePath.addArc(center: bottomRightCenter, radius: bottomRight, startAngle:0, endAngle:CGFloat(Double.pi / 2), clockwise: false)
        //左下
        mutablePath.addArc(center: bottomLeftCenter, radius: bottomLeft, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
        shaperLayer.path = mutablePath
        self.layer.mask = shaperLayer
    }
    
}

extension UIView {
    
    /**
     remove all subviews
     */
    func removeAllSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    /**
     add all subviews
     */
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { (subView) in
            addSubview(subView)
        }
    }
    
}


extension UIView {
    
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            let firstResponder = subview.findFirstResponder()
            if let tempFirstResponder = firstResponder {
                return tempFirstResponder
            }
        }
        return nil
    }
    
    func findAttachedCell() -> UITableViewCell? {
        if self.isKind(of: UITableViewCell.classForCoder()) {
            return self as? UITableViewCell
        }
        if let superView = self.superview {
            let tableViewCell = superView.findAttachedCell()
            if let tempTableViewCell = tableViewCell {
                return tempTableViewCell
            }
            return superview?.findAttachedCell()
        }
        return nil
    }
    
}




