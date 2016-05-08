//
//  WhoAppliedCell.swift
//  Gigr
//
//  Created by Kenza on 2016-04-10.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class WhoAppliedCell: UITableViewCell {

  //OUTLETS
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userName: UILabel!
  
  //PROPERTIES
  var user: GigHunter!
  var request: Request?
  
  //METHODS
  override func drawRect(rect: CGRect) {
    userImage.layer.cornerRadius = userImage.frame.size.width / 2
    userImage.clipsToBounds = true
  }
  
  func configureCell(user: GigHunter, img: UIImage?) {
    self.user = user
    self.userName.text = user.userName
    
    if user.userImg != nil {
      if img != nil {
        self.userImage.image = img
      } else {
        request = Alamofire.request(.GET, user.userImg!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          if err == nil {
            let img = UIImage(data: data!)!
            self.userImage.image = img
            FeedGigsVC.profilImgCache.setObject(img, forKey: self.user.userImg)
          }
        })
      }
    } else {
      let img = UIImage(named: "placeholderImg.png")
      self.userImage.image = img
    }
  }
}
