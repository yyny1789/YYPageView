//
//  LayoutConstants.swift
//  Tou
//
//  Created by Yangyang on 2018/7/9.
//  Copyright © 2018年 36kr. All rights reserved.
//

import UIKit

struct LayoutConstants {
    
    static var onePixel: CGFloat {
        return 1.0 / UIScreen.main.scale
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var navBarY: CGFloat {
        switch UIDevice.current.kind {
        case .iPhoneX, .iPhoneXS_MAX, .iPhone12Pro_MAX, .Unknown:
            return 20
        default:
            return 0
        }
    }
    
    static var navBarHeight: CGFloat {
        switch UIDevice.current.kind {
        case .iPhoneX, .iPhoneXS_MAX, .iPhone12Pro_MAX, .Unknown:
            return 88
        default:
            return 64
        }
    }
    
    static var tabBarHeight: CGFloat {
        switch UIDevice.current.kind {
        case .iPhoneX, .iPhoneXS_MAX, .iPhone12Pro_MAX, .Unknown:
            return 83
        default:
            return 49
        }
    }
    
    static var statusBarHeight: CGFloat {
        switch UIDevice.current.kind {
        case .iPhoneX, .iPhoneXS_MAX, .iPhone12Pro_MAX, .Unknown:
            return 44
        default:
            return 20
        }
    }
    
    static var adjustInsetForIPhoneX: UIEdgeInsets {
        switch UIDevice.current.kind {
        case .iPhoneX, .iPhoneXS_MAX, .iPhone12Pro_MAX, .Unknown:
            return UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }
    
}
