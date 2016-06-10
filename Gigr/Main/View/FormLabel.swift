//
//  FormTextField.swift
//  Gigr
//
//  Created by Kenza on 2016-04-17.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class FormLabel: UILabel {

  override func awakeFromNib() {
    let border = CALayer()
    let width = CGFloat(1)
    border.borderColor = grayColor.CGColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width + 160, height: self.frame.size.height)
    border.borderWidth = width
    layer.addSublayer(border)
    layer.masksToBounds = true
  }

}
