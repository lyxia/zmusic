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
    
    func nt_setBackgroundImageWithPattern(_ imagePicker: @escaping ImagePicker) {
        self.setBackgroundImageWithPattern(imagePicker())
        self.pickers.setObject(PickerClosureWrapper(imagePicker), forKey: NSString(string:"setBackgroundImageWithPattern:"))
    }
    
    func ns_setBackgroundImage(_ imagePicker: @escaping ImagePicker, boolKey: String, getTrue: Bool = true) {
        let newPicker: ImagePicker = {
            let boolValue = ThemeManager.shareInstance.getBool(byKey: boolKey)
            if  boolValue == getTrue {
                return imagePicker()
            } else {
                return nil
            }
        }
        self.setBackgroundImageWithPattern(newPicker())
        self.pickers.setObject(PickerClosureWrapper(newPicker), forKey: NSString(string:"setBackgroundImage:"))
    }
    
    func nt_setBackgroundImageWithPattern(_ imagePicker: @escaping ImagePicker, boolKey: String, getTrue: Bool = true) {
        let newPicker: ImagePicker = {
            let boolValue = ThemeManager.shareInstance.getBool(byKey: boolKey)
            if  boolValue == getTrue {
                return imagePicker()
            } else {
                return nil
            }
        }
        self.setBackgroundImageWithPattern(newPicker())
        self.pickers.setObject(PickerClosureWrapper(newPicker), forKey: NSString(string:"setBackgroundImageWithPattern:"))
    }
}
