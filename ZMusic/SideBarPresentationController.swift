//
//  SideBarPresentationController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/22.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import ZMusicUIFrame
import SnapKit

class SideBarPresentationController: CuzDrawerPresentationController {

    private var bgImage: UIImageView?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        bgImage = UIImageView()
        bgImage?.isUserInteractionEnabled = false
        bgImage!.translatesAutoresizingMaskIntoConstraints = false
        containerView?.insertSubview(bgImage!, at: 0)
        bgImage?.snp.makeConstraints({ [weak weakself = self] (make) in
            if let wrapSelf = weakself {
                make.edges.equalTo(wrapSelf.containerView!)
            }
        })
        bgImage?.nt_image = UIImage.nt_imageNamed("bg_sidebar")
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        if !completed {
            bgImage?.removeFromSuperview()
            bgImage = nil
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            bgImage?.removeFromSuperview()
            bgImage = nil
        }
    }
    
}
