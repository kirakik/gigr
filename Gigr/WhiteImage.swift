//
//  WhiteImage.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class WhiteImage: UIImageView {

  override func awakeFromNib() {
    image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    tintColor = UIColor.whiteColor()
  }

}
