//
//  CuzLinePresentationController.swift
//  ZMusicUIFrame
//
//  Created by lyxia on 2016/10/31.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation

public class CuzLinePresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
    }
    
    private var presentedViewPanGesture: UIPanGestureRecognizer?
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        if completed {
            //添加拖动手势
            presentedViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
            containerView?.addGestureRecognizer(presentedViewPanGesture!)
        }
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            containerView?.removeGestureRecognizer(presentedViewPanGesture!)
            presentedViewPanGesture = nil
        }
    }
    
    func panHandler(_ pan:UIPanGestureRecognizer) {
        if let containerView = self.containerView {
            let translationX = pan.translation(in: containerView).x
            let percent = translationX / containerView.bounds.width
            switch pan.state {
            case .began:
                percentInteractive = UIPercentDrivenInteractiveTransition()
                presentedViewController.dismiss(animated: true, completion: nil)
                break
            case .changed:
                if percent > 0 {
                    percentInteractive?.update(percent)
                }
                break
            default:
                if percent > 0.5 || pan.velocity(in: containerView).x > 1000 {
                    percentInteractive?.finish()
                } else {
                    percentInteractive?.cancel()
                }
                percentInteractive = nil
            }
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    private var percentInteractive: UIPercentDrivenInteractiveTransition?
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentInteractive
    }
    
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
        let fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController!)
        if isPresent {
            containerView.addSubview(toView!)
            toView?.frame = CGRect(x: toViewFinalFrame.size.width, y: 0, width: toViewFinalFrame.size.width, height: toViewFinalFrame.size.height)
        }
        
        let timeInterval = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: timeInterval,
                       animations:{
                        if isPresent {
                            toView?.frame = toViewFinalFrame
                        } else {
                            fromView?.frame = CGRect(x: fromViewFinalFrame.size.width, y: 0, width: fromViewFinalFrame.size.width, height: fromViewFinalFrame.size.height)
                        }
        },
                       completion:{(complete) in
                        let wasCancelled = transitionContext.transitionWasCancelled
                        transitionContext.completeTransition(!wasCancelled)}
        )
    }
}
