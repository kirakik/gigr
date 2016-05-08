//
//  DataService.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import Foundation
import Firebase

//GLOBAL PROPERTIES
let url_base = "https://gigr.firebaseio.com"

class DataService {
    
  //SINGLETON REFERENCE
  static let ds = DataService()
    
  //PROPERTIES
  private(set) var ref_base = Firebase(url: "\(url_base)")
  private(set) var ref_gig_posts = Firebase(url: "\(url_base)/gigPost")
  private(set) var ref_posts_cat = Firebase(url: "\(url_base)/postsByCategory")
  private(set) var ref_users = Firebase(url: "\(url_base)/users")
  private(set) var ref_users_cat = Firebase(url: "\(url_base)/usersByCategory")
  var ref_user_current: Firebase {
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(key_uid) as? String
    if uid != "" {
      let user = Firebase(url: "\(url_base)").childByAppendingPath("users").childByAppendingPath(uid)
      return user!
    }
    return Firebase()
  }
  
  //METHODS
  func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
    if uid != "" {
      ref_users.childByAppendingPath(uid).setValue(user)
    }
  }
        
}