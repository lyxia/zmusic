//
//  UIImageView+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/3.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct AssociatedKeys {
    static let ImageKey: String = "ImageKey"
}

extension UIImageView {
    var nt_image: ImagePicker? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.ImageKey) as? ImagePicker
        }
        set {
            if let imagePicker = newValue {
                let picker = PickerClosureWrapper(imagePicker)
                objc_setAssociatedObject(self, AssociatedKeys.ImageKey, picker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.image = imagePicker()
                
                self.pickers.setObject(picker, forKey: NSString(string: "setImage:"))
            }
        }
    }
}
