//
//  UIKitExtension.swift
//  ZMusicUtils
//
//  Created by lyxia on 2016/10/10.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public class var randomColor: UIColor {
        let random = arc4random() % 3
        var color: UIColor!
        switch random {
        case 0:
            color = UIColor.red
        default:
            color = UIColor.black
        }
        return color
    }
    
    static public func hexStringToColor(hexString: String) -> UIColor{
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cString.characters.count < 6 {return UIColor.black}
        
        if cString.hasPrefix("0X") {cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 2))}
        if cString.hasPrefix("#") {cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))}
        if cString.characters.count != 6 {return UIColor.black}
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
    }
}
