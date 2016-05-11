//
//  PresentationAnimVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-20.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class PresentationAnimVC: NSObject, UIViewControllerAnimatedTransitioning {
  
  /** PROPERTIES **/
  let isPresenting: Bool
  let duration: NSTimeInterval = 0.5
  
  /** INITIALIZERS **/
  init(isPresenting: Bool) {
    self.isPresenting = isPresenting
    super.init()
  }
  
  /** FUNCTIONS **/
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return self.duration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    if isPresenting {
      animatePresentationWithTransitionContext(transitionContext)
    } else {
      animateDismissalWithTransitionContext(transitionContext)
    }
  }
  
  func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
      let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey),
      let containerView = transitionContext.containerView()
      else {
        return
    }
    
    presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
    presentedControllerView.center.y -= containerView.bounds.size.height

    
    containerView.addSubview(presentedControllerView)
    
    UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
      presentedControllerView.center.y += containerView.bounds.size.height
      }, completion: {(completed: Bool) -> Void in
        transitionContext.completeTransition(completed)
    })
  }
  
  func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey),
      let containerView = transitionContext.containerView()
      else {
        return
      }
    
    // Animate the presented view off the bottom of the view
    UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
      presentedControllerView.center.y += containerView.bounds.size.height
      }, completion: {(completed: Bool) -> Void in
        transitionContext.completeTransition(completed)
    })
  }

}
