//
//  CuzNavigationBar.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/13.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit

public class CuzNavigationBar: UINavigationBar, UINavigationBarDelegate {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInt()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInt()
    }
    
    private func commonInt() {
        self.delegate = self
        self.shadowImage = UIImage()
    }
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    private var bg: UIImageView?
    public override func setBackgroundImage(_ backgroundImage: UIImage?) {
        if let backgroundImage = backgroundImage {
            if let bg = bg {
                bg.image = backgroundImage
            } else {
                bg = UIImageView(image: backgroundImage)
                bg?.contentMode = .scaleToFill
                bg?.translatesAutoresizingMaskIntoConstraints = false
                self.insertSubview(bg!, at: 1)
                let arr = [
                    NSLayoutConstraint(item: bg!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: -20),
                    NSLayoutConstraint(item: bg!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: bg!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: bg!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)]
                self.addConstraints(arr);
            }
        } else {
            bg?.removeFromSuperview()
            bg = nil
        }
    }

}
