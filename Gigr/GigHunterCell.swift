//
//  GigHuntersCell.swift
//  Gigr
//
//  Created by Kenza on 2016-04-14.
//  Copyright © 2016 Kenza. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

class GigHunterCell: UITableViewCell {
  
  //OUTLETS
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var userTagline: UILabel!
  @IBOutlet weak var userShortDesc: UILabel!
  @IBOutlet weak var favoriteButton: FavButton!
  @IBOutlet weak var contactButton: MaterialButton!
  @IBOutlet weak var flagUserButton: MaterialButton!
  
  @IBOutlet weak var contentViewGH: UIView!
  //PROPERTIES
  var gigHunter: GigHunter!
  var request: Request?
  var favoritedRef: Firebase!
  
  //METHODS
  override func drawRect(rect: CGRect) {
    userImg.layer.cornerRadius = userImg.frame.size.width / 2
    userImg.clipsToBounds = true
  }
  
  func configureCell(gigHunter: GigHunter, img: UIImage?) {
    self.gigHunter = gigHunter
    favoritedRef = DataService.ds.ref_user_current.childByAppendingPath("favoritedWho").childByAppendingPath(gigHunter.userKey)
    self.userName.text = gigHunter.userName
    self.userTagline.text = gigHunter.userTagline
    self.userShortDesc.text = gigHunter.userShortDesc
    
    if gigHunter.userImg != nil {
      if img != nil {
        self.userImg.image = img
      } else {
        request = Alamofire.request(.GET, gigHunter.userImg!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          if err == nil {
            let img = UIImage(data: data!)!
            self.userImg.image = img
            FeedGigsVC.profilImgCache.setObject(img, forKey: self.gigHunter.userImg)
          }
        })
      }
    } else {
      let img = UIImage(named: "placeholderImg.png")
      self.userImg.image = img
    }
    
    favoritedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
        // We haven't liked this person
        self.favoriteButton.setImage(UIImage(named: "heart-empty"), forState: .Normal)
      } else {
        self.favoriteButton.setImage(UIImage(named: "heart-full"), forState: .Normal)
      }
    }, withCancelBlock: { error in
      print(error.debugDescription)
    })
    
    if self.gigHunter.userKey == currentUserRef {
      self.favoriteButton.hidden = true
      self.contactButton.hidden = true
      self.flagUserButton.hidden = true
      self.contactButton.userInteractionEnabled = false
    } else {
      self.favoriteButton.hidden = false
      self.contactButton.hidden = false
      self.flagUserButton.hidden = false
      self.contactButton.userInteractionEnabled = true
    }
  }
  
}
