//
//  MateriaButton.swift
//  Gigr
//
//  Created by Kenza on 2016-03-26.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import pop

@IBDesignable
class MaterialButton: UIButton {
  
  var refStr: String?
  var category: String?
  
  @IBInspectable var cornerRadius: CGFloat = 15.0 {
    didSet {
      setUpView()
    }
  }

  override func awakeFromNib() {
    setUpView()
    layer.shadowColor = UIColor(red: shadow_color, green: shadow_color, blue: shadow_color, alpha: 0.5).CGColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSizeMake(0.0, 2.0)
  }
  
  override func prepareForInterfaceBuilder() {
    setUpView()
  }
  
  func setUpView() {
    self.layer.cornerRadius = cornerRadius
    self.addTarget(self, action: #selector(MaterialButton.scaleToSmall), forControlEvents: .TouchDown)
    self.addTarget(self, action: #selector(MaterialButton.scaleToSmall), forControlEvents: .TouchDragEnter)
    self.addTarget(self, action: #selector(MaterialButton.scaleAnimation), forControlEvents: .TouchUpInside)
    self.addTarget(self, action: #selector(MaterialButton.scaleDefault), forControlEvents: .TouchDragExit)
  }
  
  func scaleToSmall() {
    let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
    scaleAnim.toValue = NSValue(CGSize: CGSizeMake(0.95, 0.95))
    self.layer.pop_addAnimation(scaleAnim, forKey: "layerScaleSmallAnimation")
  }
  
  func scaleAnimation() {
    let scaleAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
    scaleAnim.velocity = NSValue(CGSize: CGSizeMake(3.0, 3.0))
    scaleAnim.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
    scaleAnim.springBounciness = 18
    self.layer.pop_addAnimation(scaleAnim, forKey: "layerScaleSpringAnimation")
  }
  
  func scaleDefault() {
    let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
    scaleAnim.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
    self.layer.pop_addAnimation(scaleAnim, forKey: "layerScaleDefaultAnimation")
  }

}
