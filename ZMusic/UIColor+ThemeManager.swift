//
//  UIColor+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/3.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

typealias ColorPicker = ()->UIColor?

extension UIColor {
    
    static func nt_colorPickerForId(_ id: String) -> ColorPicker {
        return {
            return ThemeManager.shareInstance.getColor(byKey: id)
        }
    }
}
