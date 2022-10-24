//
//  NSButton+Util.swift
//  Tou
//
//  Created by whc on 16/9/6.
//  Copyright © 2016年 36kr. All rights reserved.
//

import UIKit

private var pTouchAreaEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero

extension UIButton {
    enum ButtonEdgeInsetsStyle {
        case buttonEdgeInsetsStyleTop // image在上，label在下
        case buttonEdgeInsetsStyleLeft // image在左，label在右
        case buttonEdgeInsetsStyleBottom // image在下，label在上
        case buttonEdgeInsetsStyleRight // image在右，label在左
    }
    
    func layoutButtonWithEdgeInsetsStyle(_ style: ButtonEdgeInsetsStyle, imageTitleSpace: CGFloat) {
        
        // 水平居中
        contentHorizontalAlignment = .center
        
        // 1. 得到imageView和titleLabel的宽、高
        let imageWidth = imageView?.frame.size.width ?? 0
        let imageHeight = imageView?.frame.size.height ?? 0

        let labelWidth = titleLabel?.intrinsicContentSize.width ?? 0
        let labelHeight = titleLabel?.intrinsicContentSize.height ?? 0
        
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero

        // 待修改位置
        switch style {
        case .buttonEdgeInsetsStyleTop:
            titleLabel?.textAlignment = .center
            labelEdgeInsets = UIEdgeInsets(top: imageHeight + imageTitleSpace, left: -imageWidth, bottom: 0, right: 0)
            if width > imageWidth {
                imageEdgeInsets = UIEdgeInsets(top: -(labelHeight + imageTitleSpace)/2.0, left: (width - imageWidth) / 2, bottom: 0, right: (width - imageWidth) / 2 - 2)
            } else {
                imageEdgeInsets = UIEdgeInsets(top: -(labelHeight + imageTitleSpace)/2.0, left: 0, bottom: 0, right: 0)
            }
        case .buttonEdgeInsetsStyleLeft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -imageTitleSpace/2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpace/2.0, bottom: 0, right: 0)
        case .buttonEdgeInsetsStyleBottom:
            labelEdgeInsets = UIEdgeInsets(top: -10.0, left: -imageWidth, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: labelHeight+imageTitleSpace, left: 0, bottom: 0, right: -labelWidth)
        case .buttonEdgeInsetsStyleRight:
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: imageWidth+imageTitleSpace/2.0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+imageTitleSpace/2.0, bottom: 0, right: -labelWidth)
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
    var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &pTouchAreaEdgeInsets) as? NSValue {
                var edgeInsets = UIEdgeInsets.zero
                value.getValue(&edgeInsets)
                return edgeInsets
            }
            else {
                return UIEdgeInsets.zero
            }
        }
        set(newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: UIEdgeInsets.zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            objc_setAssociatedObject(self, &pTouchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.touchAreaEdgeInsets == UIEdgeInsets.zero || !self.isEnabled || self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.touchAreaEdgeInsets)
        if hitFrame.contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
}
