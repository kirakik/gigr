//
//  Post.swift
//  Gigr
//
//  Created by Kenza on 2016-03-23.
//  Copyright © 2016 Kenza. All rights reserved.
//

import Foundation
import Firebase

class Gig {
    
  //PROPERTIES
  private(set) var userName: String!
  private(set) var userImg: String!
  private(set) var gigCategory: String!
  private(set) var gigTitle: String!
  private(set) var gigDescription: String!
  private(set) var gigRate: String!
  private(set) var gigType: String!
  private(set) var gigLocation: String!
  private(set) var gigKey: String!
  private(set) var gigRef: Firebase!
  private(set) var gigRefCat: Firebase!
    
  //INITIALIZERS
  init(gigCategory: String, gigTitle: String, gigDescription: String, gigRate: String, gigType: String, gigLocation: String) {
    self.gigCategory = gigCategory
    self.gigTitle = gigTitle
    self.gigDescription = gigDescription
    self.gigRate = gigRate
    self.gigType = gigType
    self.gigLocation = gigLocation
  }
    
  init(gigKey: String, dictionary: Dictionary<String, AnyObject>) {
    self.gigKey = gigKey
    if let gigCategory = dictionary["gigCategory"] as? String {
      self.gigCategory = gigCategory
    }
    if let gigTitle = dictionary["gigTitle"] as? String {
      self.gigTitle = gigTitle
    }
    if let gigDescription = dictionary["gigDescription"] as? String {
      self.gigDescription = gigDescription
    }
    if let gigRate = dictionary["gigRate"] as? String {
      self.gigRate = gigRate
    }
    if let gigType = dictionary["gigType"] as? String {
      self.gigType = gigType
    }
    if let gigLocation = dictionary["gigLocation"] as? String {
      self.gigLocation = gigLocation
    }
    if let userImg = dictionary["userImg"] as? String {
      self.userImg = userImg
    }
    if let user = dictionary["author"] as? String {
      self.userName = user
    } else {
      self.userName = ""
    }
    self.gigRef = DataService.ds.ref_gig_posts.childByAppendingPath(self.gigKey)
  }
    
}