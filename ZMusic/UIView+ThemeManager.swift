//
//  UIView+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/4.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func nt_setBackgroundImage(_ imagePicker: @escaping ImagePicker) {
        self.setBackgroundImage(imagePicker())
        self.pickers.setObject(PickerClosureWrapper(imagePicker), forKey: NSString(string:"setBackgroundImage:"))
    }
}
