import UIKit

public extension UIDevice {
    
    enum DeviceKind: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case iPhoneXS_MAX
        case iPhone12Pro_MAX
        case iPad
        case Unknown
    }
    
    var kind: DeviceKind {
        guard userInterfaceIdiom == .phone else {
            return .iPad
        }
        
        let result: DeviceKind
        switch UIScreen.main.bounds.height {
        case 480.0:
            result = .iPhone4
        case 568.0:
            result = .iPhone5
        case 667.0:
            result = .iPhone6
        case 736.0:
            result = .iPhone6Plus
        case 812.0:
            result = .iPhoneX
        case 896.0:
            result = .iPhoneXS_MAX
        case 926.0:
            result = .iPhone12Pro_MAX
        default:
            result = .Unknown
        }
        
        return result
    }
    
    static func isPhone() -> Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    static func isPad() -> Bool {
        return UIDevice().userInterfaceIdiom == .pad
    }
    
    static func isSimulator() -> Bool {
        return Simulator.isRunning
    }
}

public struct Simulator {
    
    public static var isRunning: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

