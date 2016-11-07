//
//  CuzNavigationController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/12.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit

open class CuzNavigationController: UINavigationController, UINavigationControllerDelegate {

    var cuzInteractiveTransition: UIPercentDrivenInteractiveTransition?
    var pan: UIPanGestureRecognizer?
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()

        //自定义转场动画
        self.delegate = self

        //手势监听器
        self.interactivePopGestureRecognizer?.isEnabled = false
        
        //自定义navigation bar
        self.navigationBar.isHidden = true
    }

    //MARK - interactive animation
    func panGesture(_ pan:UIPanGestureRecognizer) {
        let progress = max(pan.translation(in: self.view).x / self.view.bounds.width, 0)
        
        if pan.state == UIGestureRecognizerState.began {
            self.cuzInteractiveTransition = UIPercentDrivenInteractiveTransition()
            _ = self.popViewController(animated: true)
            
        }
        else if pan.state == UIGestureRecognizerState.changed {
            self.cuzInteractiveTransition?.update(progress)
        } else if pan.state == UIGestureRecognizerState.cancelled || pan.state == UIGestureRecognizerState.ended {
            if progress > 0.5 || pan.velocity(in: self.view).x > 1000{
                self.cuzInteractiveTransition?.finish()
            } else {
                self.cuzInteractiveTransition?.cancel()
            }
            self.cuzInteractiveTransition = nil
        }
    }
    
    private func handlerEdgePanWithViewController(_ viewController: CuzNavigationContentController) {
        if viewControllers[0] != viewController {
            if pan == nil {
                pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
                self.view.addGestureRecognizer(pan!)
            }
        } else {
            if let pan = pan {
                self.view.removeGestureRecognizer(pan)
                self.pan = nil
            }
        }
    }
    
    //MARK - manager navigationBar, can be override ,but must use super.handlerNavigationBar(..)
    func handlerNavigationBar(_ viewController: CuzNavigationContentController) {
        if viewControllers[0] != viewController {
            viewController.cuzNavigationItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"top_back"), style: .plain, target: self, action: #selector(backTapHandler))
        }
    }
    
    func backTapHandler() {
        self.popViewController(animated: true)
    }
    
    
    //MARK -UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        assert(viewController.isKind(of: CuzNavigationContentController.self), "cuzNavigationController only manager cuzNavigationContentController")
        
        let vc = viewController as! CuzNavigationContentController
        vc.cuzNavigationItem?.title = viewController.title
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        assert(viewController.isKind(of: CuzNavigationContentController.self), "cuzNavigationController only manager cuzNavigationContentController")
        
        let vc = viewController as! CuzNavigationContentController
        handlerNavigationBar(vc)
        handlerEdgePanWithViewController(vc)
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        if animationController.isKind(of: CuzNavigationPushTransitionAnimator.self) {
            return nil
        }
        return cuzInteractiveTransition
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        switch operation {
        case .pop:
            return CuzNavigationPopTransitionAnimator()
        case .push:
            return CuzNavigationPushTransitionAnimator()
        default:
            return nil
        }
    }

}

class CuzNavigationPushTransitionAnimator: CuzNavigationTransitionAnimator {}
class CuzNavigationPopTransitionAnimator: CuzNavigationTransitionAnimator {}
