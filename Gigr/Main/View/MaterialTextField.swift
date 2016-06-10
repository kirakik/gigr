//
//  MaterialTextField.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
  
  /** ADD LINE UNDER LOGIN TEXT FIELDS **/
  override func awakeFromNib() {
    let border = CALayer()
    let width = CGFloat(1.5)
    border.borderColor = UIColor.whiteColor().CGColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width + 160, height: self.frame.size.height)
        border.borderWidth = width
    layer.addSublayer(border)
    layer.masksToBounds = true
  }
  
}
