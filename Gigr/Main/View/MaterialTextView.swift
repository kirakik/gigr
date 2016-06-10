//
//  PlaceholderTV.swift
//  Gigr
//
//  Created by Kenza on 2016-03-23.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class MaterialTextView: UITextView {

  /** DESCRIPTION TEXT VIEW **/
  override func awakeFromNib() {
    layer.cornerRadius = 2.0
    if text == "e.g. Needs to be available 3 nights a week and have experience" {
      textColor = veryLightGrayColor
    }
  }
    
  func textRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 10, 0)
  }
    
  func editingRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 10, 0)
  }

}
