//
//  CustomPresentVC.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/8.
//

import UIKit

// MARK: - CustomPresentationController

class CustomPresentationController: UIPresentationController {
    
    // MARK: - Frame Handling
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect()
        }
        
        let size = CGSize(width: containerView.bounds.width, height: 200)
        let origin = CGPoint(x: 0, y: containerView.bounds.height - size.height)
        
        return CGRect(origin: origin, size: size)
    }
    
    // MARK: - Presentation Transition
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        let dimmingView = UIView(frame: containerView!.bounds)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        containerView?.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    // MARK: - Dismissal Transition
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        if let dimmingView = containerView?.subviews.first {
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                dimmingView.alpha = 0.0
            }, completion: { _ in
                dimmingView.removeFromSuperview()
            })
        }
    }
}
