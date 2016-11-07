//
//  UIButton+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/4.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func nt_setImage(_ name: String) {
        let normalImagePicker = UIImage.nt_imageNamed(name)
        let highlightImagePicker = UIImage.nt_highlightedImageNamed(name)
        
        let normalImage = normalImagePicker()
        self.setNormalImage(normalImage)
        self.pickers.setObject(PickerClosureWrapper(normalImagePicker), forKey: NSString(string:"setNormalImage:"))
        
        if let highlightImage = highlightImagePicker() {
            self.setHighlightImage(highlightImage)
            self.pickers.setObject(PickerClosureWrapper(highlightImagePicker), forKey: NSString(string:"setHighlightImage:"))
        } else {
            self.setHighlightImage(normalImage)
            self.pickers.setObject(PickerClosureWrapper(normalImagePicker), forKey: NSString(string:"setHighlightImage:"))
        }
        
    }
    
    func setNormalImage(_ image: UIImage?) {
        self.setImage(image, for: .normal)
    }
    
    func setHighlightImage(_ image: UIImage?) {
        self.setImage(image, for: .highlighted)
    }
}
