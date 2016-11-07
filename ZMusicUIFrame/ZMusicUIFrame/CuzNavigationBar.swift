//
//  CuzNavigationBar.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/13.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import SnapKit

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
                self.insertSubview(bg!, at: 0)
                bg?.snp.makeConstraints({ (make) in
                    make.left.right.equalTo(self)
                    make.top.equalTo(self).offset(-20)
                    make.bottom.equalTo(self)
                })
            }
        } else {
            bg?.removeFromSuperview()
            bg = nil
        }
    }

}
