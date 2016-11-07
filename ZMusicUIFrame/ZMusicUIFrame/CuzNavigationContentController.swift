//
//  CuzNavigationContentController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/12.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import SnapKit

open class CuzNavigationContentController: UIViewController {
    
    public lazy var cuzNavigationItem: UINavigationItem? = {
        if let bar = self.cuzNavigationBar {
            return bar.items!.first
        }
        return nil
    }()
    
    public lazy var cuzNavigationBar: CuzNavigationBar? = {
        if let nav = self.navigationController {
            let frame = nav.navigationBar.frame
            
            let bar = CuzNavigationBar(frame: frame)
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            let item = UINavigationItem(title: "title")
            bar.pushItem(item, animated: false)
            
            return bar
        }
        return nil
    }()
    
    private var _completeLayoutBar = false
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !_completeLayoutBar {
            layoutBar()
            _completeLayoutBar = true
        }
    }
    
    private func layoutBar() {
        if let bar = cuzNavigationBar {
            self.view.addSubview(bar)
            
            bar.snp.makeConstraints({ (make) in
                make.left.right.equalTo(self.view)
                make.top.equalTo((self.navigationController?.topLayoutGuide.length) ?? self.view)
            })
        }
    }
}
