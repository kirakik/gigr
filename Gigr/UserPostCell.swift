//
//  UserPostCell.swift
//  Gigr
//
//  Created by Kenza on 2016-04-27.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class UserPostCell: UITableViewCell {

  /** IB OUTLETS **/
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var gigTitle: UILabel!
  @IBOutlet weak var gigRate: UILabel!
  @IBOutlet weak var gigType: UILabel!
  @IBOutlet weak var gigLocation: UILabel!
  @IBOutlet weak var gigDescription: UILabel!
  @IBOutlet weak var applyToGig: MaterialButton!
  @IBOutlet weak var messageButton: MaterialButton!
  
  /** PROPERTIES **/
  var gigPost: Gig!
  var request: Request?
  var appliedRef: Firebase!
  var userRef = ""
  var postKey = ""
  
  /** FUNCTIONS **/
  override func awakeFromNib() {
    super.awakeFromNib()
    userImg.layer.cornerRadius = userImg.frame.size.width / 2
    userImg.clipsToBounds = true
  }
  
  func configureCell(gigPost: Gig, img: UIImage?) {
    self.gigPost = gigPost
    self.postKey = "\(gigPost.gigKey)"
    appliedRef = DataService.ds.ref_gig_posts.childByAppendingPath(postKey).childByAppendingPath("whoApplied").childByAppendingPath(currentUserRef)
    self.userName.text = gigPost.userName.uppercaseString
    self.gigTitle.text = gigPost.gigTitle
    self.gigDescription.text = gigPost.gigDescription
    if let rate = gigPost.gigRate where rate != "" {
      self.gigRate.text = gigPost.gigRate
    } else {
      self.gigRate.text = "/"
    }
    self.gigType.text = gigPost.gigType
    self.gigLocation.text = gigPost.gigLocation
    
    if gigPost.userImg != nil {
      if img != nil {
        self.userImg.image = img
      } else {
        request = Alamofire.request(.GET, gigPost.userImg!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          if err == nil {
            let img = UIImage(data: data!)!
            self.userImg.image = img
            FeedGigsVC.profilImgCache.setObject(img, forKey: self.gigPost.userImg)
          }
        })
      }
    } else {
      let img = UIImage(named: "placeholderImg.png")
      self.userImg.image = img
    }
  
    checkIfUserApplied()
  }

  func checkIfUserApplied() {
    appliedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
        // We haven't applied to this gig
        self.applyToGig.setTitle("I'M INTERESTED", forState: UIControlState.Normal)
        self.applyToGig.backgroundColor = purpleButtonColor
      } else {
        self.applyToGig.setTitle("YOU APPLIED", forState: UIControlState.Normal)
        self.applyToGig.backgroundColor = greenButtonColor
      }
      }, withCancelBlock: { error in
        print(error.debugDescription)
    })
  }
  
}
