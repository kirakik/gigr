//
//  PresentationVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-20.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class PresentationVC: UIPresentationController {
  
  /** PROPERTIES **/
  lazy var dimmingView: UIView = {
    let myView = UIView(frame: self.containerView!.bounds)
    myView.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 102/255.0, alpha: 0.2)
    myView.alpha = 0.0
    return myView
  }()
  
  /** FUNCTIONS **/
  override func presentationTransitionWillBegin() {
    guard
      let containerView = containerView,
      let presentedView = presentedView()
    else {
        return
    }
    
    dimmingView.frame = containerView.bounds
    containerView.addSubview(dimmingView)
    containerView.addSubview(presentedView)
    
    if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
      transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        self.dimmingView.alpha = 1.0
      }, completion:  nil)
    }
  }
  
  override func presentationTransitionDidEnd(completed: Bool) {
    if !completed {
      self.dimmingView.removeFromSuperview()
    }
  }
  
  override func frameOfPresentedViewInContainerView() -> CGRect {
    guard
      let containerView = containerView
    else {
      return CGRect()
    }
    var frame = containerView.bounds
    frame = CGRectInset(frame, 0, 0)
    return frame
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    guard
      let containerView = containerView
    else {
      return
    }
    
    coordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
      self.dimmingView.frame = containerView.bounds
    }, completion: nil)
  }
  
}
