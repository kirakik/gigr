//
//  AnimationEngine.swift
//  Gigr
//
//  Created by Kenza on 2016-04-17.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import pop

class AnimationEngine {
  
  //CLASS PROPERTIES
  class var offScreenTopPosition: CGPoint {
    return CGPointMake(UIScreen.mainScreen().bounds.height, CGRectGetMidX(UIScreen.mainScreen().bounds))
  }
  
  class var offScreenBottomPosition: CGPoint {
    return CGPointMake(UIScreen.mainScreen().bounds.height, CGRectGetMidX(UIScreen.mainScreen().bounds))
  }
  
  class var screenCenterPosition: CGPoint {
    return CGPointMake(CGRectGetMidX(UIScreen.mainScreen().bounds), CGRectGetMidX(UIScreen.mainScreen().bounds))
  }
  
  //PROPERTIES
  var originalConstants = [CGFloat]()
  var constraints: [NSLayoutConstraint]!
  
  //INITIALIZERS
  init(constraints: [NSLayoutConstraint]) {
    for con in constraints {
      originalConstants.append(con.constant)
      con.constant = AnimationEngine.offScreenBottomPosition.y + 400
    }
    self.constraints = constraints
  }
  
  //METHODS
  func animateOnScreen(delay: Int?) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay!) * Double(NSEC_PER_SEC)))
    
    dispatch_after(time, dispatch_get_main_queue()) {
      var index = 0
      repeat {
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        moveAnim.toValue = self.originalConstants[index]
        moveAnim.springBounciness = 5
        moveAnim.springSpeed = 8
        
        let con = self.constraints[index]
        con.pop_addAnimation(moveAnim, forKey: "moveOnScreen")
        
        index += 1
      } while (index < self.constraints.count)
    }
  }
  
}
















