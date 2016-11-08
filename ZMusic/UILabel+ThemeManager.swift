//
//  UILabel+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/8.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func nt_setTextColor(_ colorPicker: @escaping ColorPicker){
        self.textColor = colorPicker()
        self.pickers.setObject(PickerClosureWrapper(colorPicker), forKey: NSString(string:"setTextColor:"))
    }
}
