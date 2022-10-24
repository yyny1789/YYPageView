//
//  String+Utils.swift
//  Tou
//
//  Created by aidenluo on 1/25/16.
//  Copyright © 2016 36kr. All rights reserved.
//

import Foundation
import UIKit

enum AliyunImageMode {
    /// (默认值）等比缩放，缩放图限制为指定w与h的矩形内的最大图片,  想按比例获取图片，只设置width或者height即可，另一个设为0
    case lfit(width: CGFloat, height: CGFloat)
    /// 等比缩放，缩放图为延伸出指定w与h的矩形框外的最小图片，, 想按比例获取图片，只设置width或者height即可，另一个设为0
    case mfit(width: CGFloat, height: CGFloat)
    /// 将原图等比缩放为延伸出指定w与h的矩形框外的最小图片，之后将超出的部分进行居中裁剪。
    case fill(width: CGFloat, height: CGFloat)
    /// 将原图缩放为指定w与h的矩形内的最大图片，之后使用指定颜色居中填充空白部分。
    case pad(width: CGFloat, height: CGFloat)
    /// 固定宽高，强制缩放
    case fixed(width: CGFloat, height: CGFloat)
    
    fileprivate var value: String {
        switch self {
        case .lfit:
            return "lfit"
        case .mfit:
            return "mfit"
        case .fill:
            return "fill"
        case .pad:
            return "pad"
        case .fixed:
            return "fixed"
        }
    }
}

extension String {
    
    var safeIntegerValue: Int? {
        let result = (self as NSString).integerValue
        if result >= 0 {
            return result
        }
        return nil
    }
    
    func split(_ delimiter: String) -> [String] {
        let components = self.components(separatedBy: delimiter)
        return components != [""] ? components : []
    }
    
    func isIncludeChinese() -> Bool {
        for (_, value) in self.enumerated() {
            if "\u{4E00}" <= value && value <= "\u{9FA5}" {
                return true
            }
        }
        return false
    }

    var urlValue: URL? {
        // " "、"×" 都属于特殊字符
        if isIncludeChinese() || self.contains(" ") || self.contains("×") {
            let charSet = NSMutableCharacterSet()
            charSet.formUnion(with: CharacterSet.urlQueryAllowed)
            charSet.addCharacters(in: "#")
            if let tmp = self.addingPercentEncoding(withAllowedCharacters: charSet as CharacterSet){
//            if let tmp = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return URL(string: tmp)
            } else {
                return nil
            }
        } else {
            return URL(string: self)
        }
    }
    
    var length: Int {
        return self.count
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var ordinal: String? {
        let format = NumberFormatter()
        format.numberStyle = .ordinal
        return format.string(from: NSNumber(value: NSString(string: self).floatValue))
    }
    
    /// 从String中截取出参数
    var urlParameters: [String: Any]? {
        // 判断是否有参数
//        guard let start = self.range(of: "?") else {
//            return nil
//        }
        guard let start = self.range(of: "?", options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) else {
            return nil
        }
        var params = [String: Any]()
        // 截取参数
//        let index = <#T##String.CharacterView corresponding to your index##String.CharacterView#>.index(start.lowerBound, offsetBy: 1)
        
        ///TODO: 修改
    
//        let index = String.index(start)
        //subString = string[startIndex...string.index(startIndex, offsetBy
//        let index =     //start.lowerBound.index(startIndex, offsetBy//advancedBy(1)
        
        let paramsString = String(self[index(start.lowerBound, offsetBy: 1)...])//  substring(from: index)
        
        // 判断参数是单个参数还是多个参数
        if paramsString.contains("&") {
            
            // 多个参数，分割参数
            let urlComponents = paramsString.components(separatedBy: "&")
            
            // 遍历参数
            for keyValuePair in urlComponents {
                // 生成Key/Value
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first?.removingPercentEncoding
                let value = pairComponents.last?.removingPercentEncoding
                // 判断参数是否是数组
                if let key = key, let value = value {
                    // 已存在的值，生成数组
                    if let existValue = params[key] {
                        if var existValue = existValue as? [Any] {
                            
                            existValue.append(value)
                        } else {
                            params[key] = [existValue, value]
                        }
                        
                    } else {
                        
                        params[key] = value
                    }
                    
                }
            }
            
        } else {
            
            // 单个参数
            let pairComponents = paramsString.components(separatedBy: "=")
            
            // 判断是否有值
            if pairComponents.count == 1 {
                return nil
            }
            
            let key = pairComponents.first?.removingPercentEncoding//stringByRemovingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding//stringByRemovingPercentEncoding
            if let key = key, let value = value {
                params[key] = value
            }
            
        }
        return params
    }
    
    func isAllBlank() -> Bool {
        let set = CharacterSet.whitespacesAndNewlines
        let trimedString = self.trimmingCharacters(in: set)
        if trimedString.length == 0 {
            return  true
        } else {
            return false
        }
    }
    
    func contains(_ other: String) -> Bool {
        if other.isEmpty {
            return true
        }
        return self.range(of: other) != nil
    }
    
    func containsNoEmpty(_ other: String?) -> Bool {
        guard let str = other else {return false}
        if str.isEmpty {
            return false
        }
        return self.range(of: str) != nil
    }
    
    func find(_ char: Character) -> Index? {
        return self.firstIndex(of: char)
    }
    
    func trimWhiteSpaceCharacters() -> String? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return  trimmedString == "" ? nil : trimmedString
    }
    
    /**
     将 String 用指定的 Separator 切割成 String 数组
     
     - parameter separator: 要用的 Separator, 默认为空格
     
     - returns: 一个切割好的 String 数组
     */
    func segmentsWithSeparator(_ separator: Character = " ") -> [String] {
        return self.split(separator: separator).map(String.init)
    }
    
    func findSize(constrainedToWidth width: CGFloat, andFont font: UIFont) -> CGSize {
        var size = CGSize.zero
        size = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size
        return size
    }
    
    func findSize(constrainedToHeight height: CGFloat, andFont font: UIFont) -> CGSize {
        var size = CGSize.zero
        size = (self as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size
        return size
    }
    
    func findHeight(_ width: CGFloat, height: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont) -> CGFloat {
        let height = (self as NSString).boundingRect(with: CGSize(width: width, height: height),
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [NSAttributedString.Key.font : font],
                                                        context: nil).size.height
        return ceil(height)
    }
    
    func findHeight(_ width: CGFloat, height: CGFloat = CGFloat.greatestFiniteMagnitude, attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let height = (self as NSString).boundingRect(with: CGSize(width: width, height: height),
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: attributes,
                                                        context: nil).size.height
        return ceil(height)
    }
    
    func findWidth(_ height: CGFloat, width: CGFloat = CGFloat.greatestFiniteMagnitude, attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let width = (self as NSString).boundingRect(with: CGSize(width: width, height: height),
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: attributes,
                                                        context: nil).size.width
        return ceil(width)
    }
    
    static func randomStringWithLength(_ len : Int) -> NSString {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: len)
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    /**
     String 变换为 [String: AnyObject]?
     
     - returns: [String: AnyObject]?
     */
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        return nil
    }

    //生成富文本
    func toAttributedString(_ font: UIFont, _ color: UIColor? = nil) -> NSAttributedString {
        var att = [NSAttributedString.Key : Any]()
        att[.font] = font
        if let forgroundColor = color {
            att[.foregroundColor] = forgroundColor
        }
        return NSAttributedString.init(string: self, attributes: att)
    }
    
    func toAttributedString(_ attribute: [NSAttributedString.Key: Any]?) -> NSAttributedString {
        guard let att = attribute else { return NSAttributedString(string: self) }
        return NSAttributedString.init(string: self, attributes: att)
    }
    
    func toMutableAttributedString(_ font: UIFont, _ color: UIColor? = nil) -> NSMutableAttributedString {
        var att = [NSAttributedString.Key : Any]()
        att[.font] = font
        if let forgroundColor = color {
            att[.foregroundColor] = forgroundColor
        }
        return NSMutableAttributedString.init(string: self, attributes: att)
    }
    
    func toMutableAttributedString(_ attribute: [NSAttributedString.Key: Any]?) -> NSMutableAttributedString {
        guard let att = attribute else { return NSMutableAttributedString(string: self) }
        return NSMutableAttributedString.init(string: self, attributes: att)
    }
    
    //类方法
    //字符串判空
    static func isEmpty(string: String?, trim: Bool = false) -> Bool {
        guard var str = string else { return true}
        if trim {
            str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return str.isEmpty
    }
    
    //判断字符串为空时替换
    static func replaceEmptyString(string: String?, replaceString: String = "",
                                   trim: Bool = false) -> String {
        guard let str = string,
              self.isEmpty(string: str, trim: trim) == false else {
            return replaceString
        }
        return str
    }

    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    /// 剔除HTML标签
    func removeHTMLLabel() -> String {
        let tmp = self.pregReplace(pattern: "<[^>]*>", with: "")
        return tmp.replacingOccurrences(of: "&nbsp;", with: "")
    }

    /// 过滤器 将.2f格式化的字符串，去除末尾0
    ///
    /// - Parameter numberString: .2f格式化后的字符串
    /// - Returns: 去除末尾0之后的
    func removeSuffix() -> String {
        if self.count > 1 {
            let strs = self.components(separatedBy: ".")
            let last = strs.last!
            if strs.count == 2 {
                if last == "00" {
                    let indexEndOfText = self.index(self.endIndex, offsetBy:-3)
                    return String(self[..<indexEndOfText])
                } else {
                    let indexStartOfText = self.index(self.endIndex, offsetBy:-1)
                    let str = self[indexStartOfText...]
                    let indexEndOfText = self.index(self.endIndex, offsetBy:-1)
                    if str == "0" {
                        return String(self[..<indexEndOfText])
                    }
                }
            }
            return self
        } else {
            return ""
        }
    }
    
    func removeLastZero() -> String {
        guard self.contains("."), self.hasSuffix("0") else { return self }
        let str1 = self.replaceString(pattern: "0+$", with: "")
        let str2 = str1.replaceString(pattern: "\\.0*$", with: "")
        return str2
    }
    
    func replaceString(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: options)
            return regular.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)
        } catch let error {
            debugPrint(error)
            return self
        }
    }
}

// MARK: ============== HTML数据转换 ==============
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) // , .characterEncoding:String.Encoding.utf8.rawValue
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}










