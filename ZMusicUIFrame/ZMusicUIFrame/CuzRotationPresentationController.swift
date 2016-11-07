//
//  CuzRotationPresentationController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/18.
//  Copyright © 2016年 lyxia. All rights reserved.
//

/**
 class CuzTabBarViewController: UITabBarController {
 
 var rotationTransition: CuzRotationPresentationController!
 var nav: UIViewController!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 //cuzTabBar
 let cuzTabBar = UIView(frame: self.tabBar.frame)
 cuzTabBar.backgroundColor = UIColor.cyan
 cuzTabBar.translatesAutoresizingMaskIntoConstraints = false
 self.tabBar.addSubview(cuzTabBar)
 
 cuzTabBar.snp.makeConstraints { (make) in
 make.edges.equalToSuperview()
 }
 
 cuzTabBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:))))
 
 //desVC
 let desVC = UIViewController()
 desVC.view.backgroundColor = UIColor.orange
 nav = UINavigationController(rootViewController: desVC)
 desVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(dismissWithAnimal))
 
 //rotationTransition
 rotationTransition = CuzRotationPresentationController(presentedViewController: nav, presenting: self)
 nav.transitioningDelegate = rotationTransition
 }
 
 
 
 func tapHandler(_ gesture: UITapGestureRecognizer) {
 self.present(nav, animated: true, completion: nil)
 }
 
 func dismissWithAnimal() {
 self.presentedViewController?.dismiss(animated: true, completion: nil)
 }
 
 }
 */

import UIKit

public class CuzRotationPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    private var targetEdge: UIRectEdge = .right
    private var presentedViewPanGesture: UIPanGestureRecognizer?
    
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 2)
    }
    
    //UIPresentationController
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentedViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
            presentedView?.addGestureRecognizer(presentedViewPanGesture!)
        }
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentedView?.removeGestureRecognizer(presentedViewPanGesture!)
        }
    }
    
    func panHandler(_ gesture: UIPanGestureRecognizer) {
        if let containerView = self.containerView {
            
            let diffx = gesture.translation(in: containerView).x
            let process = (diffx / containerView.bounds.maxX)
            let rotationAngle = CGFloat(M_PI / 5.5) * process
            
            presentedView?.transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            if gesture.state != .began && gesture.state != .changed  {
                if (CGFloat.abs(gesture.velocity(in: containerView).x) < 1000) {
                    if CGFloat.abs(process) < 0.7 {
                        //还原
                        UIView.animate(withDuration: TimeInterval(process * 0.3), animations: {
                            self.presentedView?.transform = CGAffineTransform.identity
                        })
                        return
                    }
                }
                //执行完消失动画
                targetEdge = rotationAngle > 0 ? .right : .left
                presentedViewController.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    //UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(self.presentedViewController == presented, "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(self.presentedViewController).")
        return self
    }
    
    //UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        let isPresent = (toViewController?.presentingViewController == fromViewController)
        
        let toView: UIView?
        let fromView: UIView?
        if transitionContext.responds(to: #selector(UIViewControllerContextTransitioning.view(forKey:))) {
            toView = transitionContext.view(forKey: .to)
            fromView = transitionContext.view(forKey: .from)
        } else {
            toView = toViewController?.view
            fromView = fromViewController?.view
        }
        let containerView = transitionContext.containerView
        
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController!)
        if isPresent {
            containerView.addSubview(toView!)
            toView?.transform = CGAffineTransform.identity
            toView?.frame = toViewFinalFrame
            if targetEdge == .right {
               toView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/5.5))
            } else if targetEdge == .left {
                toView?.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/5.5))
            }
        }
        
        let timeInterval = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: timeInterval, animations: {
            if isPresent {
                toView?.transform = CGAffineTransform.identity
            } else {
                if self.targetEdge == .right {
                    fromView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/5.5))
                }else if self.targetEdge == .left{
                    fromView?.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/5.5))
                }
            }
        }) { (complete) in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
}
