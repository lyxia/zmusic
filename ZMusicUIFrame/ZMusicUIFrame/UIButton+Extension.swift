//
//  UIButton+Extension.swift
//  ZMusicUIFrame
//
//  Created by lyxia on 2016/10/24.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

public enum CuzUIButtonStyle {
    case ImageLeftTitle
    case ImageUpTitle
    case ImageRightTitle
    case ImageDownTitle
}

public extension UIButton {
    public func updatePosition(withStyle style: CuzUIButtonStyle, spacing: CGFloat) {
        if let imageView = self.imageView {
            if let title = self.titleLabel {
                switch style {
                case .ImageUpTitle:
                    let imageSize = imageView.bounds.size
                    var titleSize = title.bounds.size
                    let textSize = (title.text! as NSString).size(attributes: [NSFontAttributeName : title.font])
                    let textFrameSize = CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
                    if titleSize.width + 0.5 < textFrameSize.width {
                        titleSize.width = textFrameSize.width
                    }
                    let totalHeight = imageSize.height + titleSize.height + spacing
                    self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0.0, 0.0, -titleSize.width);
                    self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(totalHeight - titleSize.height), 0);
                case .ImageDownTitle:
                    self.imageEdgeInsets = UIEdgeInsets(top: title.bounds.maxY + spacing, left: 0, bottom: 0, right: -title.bounds.size.width)
                    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.maxX, bottom: 0, right: 0)
                case .ImageLeftTitle:
                    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
                case .ImageRightTitle:
                    self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -title.bounds.size.width)
                    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.maxX, bottom: 0, right: 0)
                }
            }
        }
    }
}
