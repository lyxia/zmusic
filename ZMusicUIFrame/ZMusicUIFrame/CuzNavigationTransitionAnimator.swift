//
//  CuzNavigationTransitionAnimator.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/12.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import UIKit

class CuzNavigationTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let scale: CGFloat = 0.95
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController: UIViewController! = transitionContext.viewController(forKey: .from)
        let toViewControlller: UIViewController! = transitionContext.viewController(forKey: .to)
        
        let fromView: UIView! = transitionContext.view(forKey: .from)
        let toView: UIView! = transitionContext.view(forKey: .to)
        let containerView: UIView = transitionContext.containerView
        
        let viewControllers: [UIViewController]! = fromViewController.navigationController?.viewControllers
        let isPush = (viewControllers.index(of: toViewControlller))! > (viewControllers.index(of: fromViewController)) ?? Int.max
        
        let fromFrame = transitionContext.initialFrame(for: fromViewController)
        let toFrame = transitionContext.finalFrame(for: toViewControlller)
        if isPush {
            fromView.frame = fromFrame
            toView.frame = toFrame.offsetBy(dx: toFrame.size.width, dy: 0.0)
        } else {
            fromView.frame = fromFrame
            toView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        let background = UIView(frame: containerView.bounds)
        background.backgroundColor = .black
        containerView.insertSubview(background, at: 0)
        if isPush {
            containerView.addSubview(toView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: transitionDuration,
            animations: {[weak weakSelf = self] in
                if let curSelf = weakSelf {
                    if isPush {
                        fromView.transform = CGAffineTransform(scaleX: curSelf.scale, y: curSelf.scale)
                        toView.frame = toFrame
                    } else {
                        fromView.frame = fromFrame.offsetBy(dx: fromFrame.size.width, dy: 0.0)
                        toView.transform = CGAffineTransform.identity
                    }
                }
            }) { (finished) in
                let wasCancelled = transitionContext.transitionWasCancelled
                if wasCancelled {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(!wasCancelled)
        }
    }
}
