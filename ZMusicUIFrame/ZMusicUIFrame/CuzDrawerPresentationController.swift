//
//  CuzDrawerPresentationController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/14.
//  Copyright © 2016年 lyxia. All rights reserved.
//

/**
 class RootViewController: CuzNavigationContentController {
 
 var desVC: DestinationViewController!
 var drawerPresentation: CuzDrawerPresentationController!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 desVC = DestinationViewController()
 drawerPresentation = CuzDrawerPresentationController(presentedViewController: desVC, presenting: self)
 
 let rightEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action:#selector(edgePanHandler(gesture:)))
 rightEdgePan.edges = .right
 self.view.addGestureRecognizer(rightEdgePan)
 
 let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action:#selector(edgePanHandler(gesture:)))
 leftEdgePan.edges = .left
 self.view.addGestureRecognizer(leftEdgePan)
 }
 
 func edgePanHandler(gesture: UIScreenEdgePanGestureRecognizer) {
 if gesture.state == .began {
 if gesture.edges == .right {
 drawerPresentation.targetEdge = .left
 } else if gesture.edges == .left {
 drawerPresentation.targetEdge = .right
 }
 }
 drawerPresentation.presentGestureHandler(gesture: gesture)
 }
 }
 */

import UIKit

open class CuzDrawerPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    public var targetEdge: UIRectEdge!
    
    private var dismissGesture: UIGestureRecognizer?
    private var percentInteraction: UIPercentDrivenInteractiveTransition?
    
    private var dimmingView: UIView?
    private weak var originSuperView: UIView?
    
    private let presentedAnimalScale: CGFloat = 0.8
    private let presentingAnimalScale: CGFloat = 0.7
    private let percentFinish: CGFloat = 0.4
    private let presentedWidthScale: CGFloat = 0.85
    private let presentedHeightScale: CGFloat = 1.0
    
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
    }
    
    //Mark - UIPresentationController
    override open func presentationTransitionWillBegin() {
        
        originSuperView = presentingViewController.view.superview
        
        self.containerView?.addSubview(presentedView!)
        self.containerView?.addSubview(presentingViewController.view)
    }
    
    override open func presentationTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            //add tap dismiss
            let dimmingView = UIView()
            dimmingView.backgroundColor = UIColor.clear
            dimmingView.frame = presentingViewController.view.frame
            self.containerView?.addSubview(dimmingView)
            
            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingTapHandler(gesture:))))
            
            self.dimmingView = dimmingView
            
            //add interaction dismiss
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(dismissGestureHandler(gesture:)))
            containerView?.addGestureRecognizer(gesture)
            dismissGesture = gesture
        }
        else {
            if let superView = originSuperView {
                superView.addSubview(presentingViewController.view)
            }
        }
    }
    
    func dimmingTapHandler(gesture: UIGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override open func dismissalTransitionWillBegin() {
    }
    
    override open func dismissalTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            
            //remove tap dismiss
            dimmingView?.removeFromSuperview()
            dimmingView = nil
            
            //remove interaction dismiss
            dismissGesture?.removeTarget(self, action: #selector(dismissGestureHandler(gesture:)))
            
            if let superView = originSuperView {
                superView.addSubview(presentingViewController.view)
            }
        }
    }
    
    override open var frameOfPresentedViewInContainerView: CGRect {
        
        let presentedViewSize = CGSize(width: (containerView?.bounds.size.width)! * presentedWidthScale, height: (containerView?.bounds.size.height)! * presentedHeightScale)
        if targetEdge == UIRectEdge.right {
            return CGRect(origin: CGPoint.zero, size: presentedViewSize)
        } else if targetEdge == UIRectEdge.left {
            return CGRect(origin: CGPoint(x:(containerView?.bounds.size.width)! - presentedViewSize.width, y:0), size: presentedViewSize)
        }
        return CGRect.zero
    }
    
    //Mark - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let isPresent = (fromViewController == presentingViewController)
        
        let toView = toViewController.view
        let fromView = fromViewController.view
        let containerView = transitionContext.containerView
        
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        let fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        
        if isPresent {
            //初始化toview的位置
            toView?.transform = CGAffineTransform.identity
            toView?.frame = toViewFinalFrame
            toView?.transform = CGAffineTransform(scaleX: presentedAnimalScale, y: presentedAnimalScale)
        }
        
        let transitionDuring = self.transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: transitionDuring,
            animations: {
                if isPresent {
                    //执行presented动画
                    toView?.transform = CGAffineTransform.identity
                    //执行presenting动画
                    if self.targetEdge == .right {
                        fromView?.transform = CGAffineTransform.identity.translatedBy(x: toViewFinalFrame.size.width - (fromViewFinalFrame.size.width - fromViewFinalFrame.size.width * self.presentingAnimalScale)/2, y: 0).scaledBy(x: self.presentingAnimalScale, y: self.presentingAnimalScale)
                    } else if self.targetEdge == .left {
                        let a = fromViewFinalFrame.size.width * self.presentingAnimalScale - (containerView.bounds.size.width - toViewFinalFrame.size.width)
                        let b = (fromViewFinalFrame.size.width - fromViewFinalFrame.size.width * self.presentingAnimalScale)/2
                        fromView?.transform = CGAffineTransform.identity.translatedBy(x: -a - b, y: 0).scaledBy(x: self.presentingAnimalScale, y: self.presentingAnimalScale)
                    }
                    
                    
                } else {
                    //执行presenting动画
                    toView?.transform = CGAffineTransform.identity
                    //执行presented动画
                    fromView?.transform = CGAffineTransform(scaleX: self.presentedAnimalScale, y: self.presentedAnimalScale)
                }
            }) { (complete) in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
        }
    }
    
    //Mark - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController)
        -> UIPresentationController?
    {
        assert(self.presentedViewController == presented, "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(self.presentedViewController).")
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentInteraction
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentInteraction
    }
    
    //Mark - interaction
    public func presentGestureHandler(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            percentInteraction = UIPercentDrivenInteractiveTransition()
            presentingViewController.present(presentedViewController, animated: true, completion: nil)
        case .changed:
            percentInteraction?.update(getPercentProcess(gesture: gesture))
        default:
            let process = getPercentProcess(gesture: gesture)
            let velocityX = gesture.velocity(in: containerView).x
            if (targetEdge == .right && velocityX > 1000) ||
                (targetEdge == .left && velocityX < -1000) ||
                process > percentFinish
            {
                percentInteraction?.finish()
            } else {
                percentInteraction?.cancel()
            }
            percentInteraction = nil
        }
    }
    
    func dismissGestureHandler(gesture: UIGestureRecognizer) {
        if let pan = gesture as? UIPanGestureRecognizer, let containerView = self.containerView {
            var process: CGFloat = 0.0
            if targetEdge == .right {
                process = -min(pan.translation(in: containerView).x, 0)
            } else if targetEdge == .left{
                process = max(0, pan.translation(in: containerView).x)
            }
            process /= containerView.bounds.width
            
            switch gesture.state {
            case .began:
                percentInteraction = UIPercentDrivenInteractiveTransition()
                presentedViewController.dismiss(animated: true, completion: nil)
            case .changed:
                percentInteraction?.update(min(process, 1))
            default:
                let velocityX = pan.velocity(in: containerView).x
                if (targetEdge == .right && velocityX < -1000) ||
                    (targetEdge == .left && velocityX > 1000) ||
                    process > (1 - percentFinish)
                {
                    percentInteraction?.finish()
                } else {
                    percentInteraction?.cancel()
                }
                percentInteraction = nil
            }
        }
    }
    
    func getPercentProcess(gesture: UIPanGestureRecognizer) -> CGFloat{
        if let containerView = self.containerView {
            var process: CGFloat = 0.0
            if targetEdge == .right {
                process = max(gesture.translation(in: containerView).x, 0)
            } else if targetEdge == .left{
                process = -min(0, gesture.translation(in: containerView).x)
            }
            process /= containerView.bounds.width
            return min(process, 1)
        }
        return 0
    }
}
