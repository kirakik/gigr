//
//  MyPostCell.swift
//  Gigr
//
//  Created by Kenza on 2016-04-09.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class MyPostCell: UICollectionViewCell {
  
  /** IB OUTLETS **/
  @IBOutlet weak var postTitle: UILabel!
  
  /** PROPERTIES **/
  var post: Gig!
  
  /** FUNCTIONS **/
  override func drawRect(rect: CGRect) {
    postTitle.layer.cornerRadius = postTitle.frame.size.width / 2
    postTitle.clipsToBounds = true
  }
  
  func configureCell(post: Gig) {
    self.post = post
    postTitle.text = post.gigTitle
  }
  
}
