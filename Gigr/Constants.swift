//
//  Constants.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// PROPERTIES
let grayColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
let myLightGrayColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 201/255.0, alpha: 0.5)
let veryLightGrayColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 201/255.0, alpha: 1)
let veryVeryLightGrayColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 201/255.0, alpha: 0.1)
let darkerGrayColor = UIColor(red: 156/255.0, green: 160/255.0, blue: 160/255.0, alpha: 0.84)
let purpleButtonColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 102/255.0, alpha: 0.78)
let greenButtonColor = UIColor(red: 63/255.0, green: 152/255.0, blue: 116/255.0, alpha: 0.7)
let greyButtonColor = UIColor(red: 121/255.0, green: 121/255.0, blue: 127/255.0, alpha: 1)
let shadow_color: CGFloat = 157.0 / 255.0
let hospitality = "Hospitality"
let customer = "CustomerService"
let artists = "Artists"
let tv = "TVMediaFashion"
let office = "Office"
let child = "ChildPet"
let construction = "Construction"
let security = "Security"
let tech = "Technology"
let health = "Healthcare"
let salon = "Salon"
let retail = "Retail"
let other = "Other"

// KEYS
let key_uid = "uid"
let currentUserUID = NSUserDefaults.standardUserDefaults().valueForKey(key_uid) as? String
let currentUserRef = "\(currentUserUID!)"

// SEGUES
let segue_login = "LoginIdentifier"
let segue_registered = "RegisteredSegue"

// STATUS CODES
let status_account_nonexist = -8

// EXTENSIONS
extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
}

extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.nextResponder()
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

extension UITableView {
  func reloadDataKeepingOffset() {
    let offset = contentOffset
    UIView.setAnimationsEnabled(false)
    beginUpdates()
    endUpdates()
    UIView.setAnimationsEnabled(true)
    layoutIfNeeded()
    contentOffset = offset
  }
}

