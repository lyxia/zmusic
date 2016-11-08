//
//  UIImage+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/3.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

typealias ImagePicker = ()->UIImage?

extension UIImage {
    
    static func nt_imageNamed(_ name: String, defaultImage: UIImage? = nil) -> ImagePicker {
        return {
            return ThemeManager.shareInstance.getImage(byKey: name) ?? defaultImage ?? UIImage(named: name)
        }
    }
    
    static func nt_highlightedImageNamed(_ name: String, defaultImage: UIImage? = nil) -> ImagePicker {
        return {
            return ThemeManager.shareInstance.getHighlightedImage(byKey: name) ?? defaultImage ?? UIImage(named: name)
        }
    }
    
    static func nt_imageNamed(_ name: String, resizableCapInsets insets: UIEdgeInsets, resizeMode: UIImageResizingMode = .stretch) -> ImagePicker {
        return {
            if let image = nt_imageNamed(name)() {
                return image.resizableImage(withCapInsets: insets, resizingMode: resizeMode)
            }
            return nil
        }
    }
}
