//
//  GigHunter.swift
//  Gigr
//
//  Created by Kenza on 2016-03-23.
//  Copyright © 2016 Kenza. All rights reserved.
//

import Foundation
import Firebase

class GigHunter {

  /** PROPERTIES **/
  private(set) var userName: String!
  private(set) var userCategory: String!
  private(set) var userLocation: String!
  private(set) var userTagline: String!
  private(set) var userImg: String!
  private(set) var userShortDesc: String!
  private(set) var userLongDesc: String!
  private(set) var userAvailabilities: String!
  private(set) var userSkills: String!
  private(set) var userKey: String!

  /** INITIALIZERS **/
  init(userName: String, userCategory: String, userLocation: String, userTagline: String, userImg: String, userShortDesc: String) {
    self.userName = userName
    self.userLocation = userLocation
    self.userCategory = userCategory
    self.userTagline = userTagline
    self.userImg = userImg
    self.userShortDesc = userShortDesc
    self.userLongDesc = ""
    self.userAvailabilities = ""
    self.userSkills = ""
  }
    
  init(userKey: String, dictionary: Dictionary<String, AnyObject>) {
    self.userKey = userKey
    if let userName = dictionary["name"] as? String {
      self.userName = userName
    }
    if let userLocation = dictionary["location"] as? String {
      self.userLocation = userLocation
    }
    if let userCategory = dictionary["category"] as? String {
      self.userCategory = userCategory
    }
    if let userTagline = dictionary["tagline"] as? String {
      self.userTagline = userTagline
    }
    if let userImg = dictionary["userImg"] as? String {
      self.userImg = userImg
    }
    if let userShortDesc = dictionary["shortDesc"] as? String {
      self.userShortDesc = userShortDesc
    }
    if let userAvailabilities = dictionary["availabilities"] as? String {
      self.userAvailabilities = userAvailabilities
    }
    if let userSkills = dictionary["skills"] as? String {
      self.userSkills = userSkills
    }
  }
    
}