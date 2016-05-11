//
//  PostCell.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class PostCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
  //OUTLETS
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var gigTitle: UILabel!
  @IBOutlet weak var editTitle: UITextField!
  @IBOutlet weak var gigRate: UILabel!
  @IBOutlet weak var editRate: UITextField!
  @IBOutlet weak var gigType: UILabel!
  @IBOutlet weak var editType: UITextField!
  @IBOutlet weak var gigLocation: UILabel!
  @IBOutlet weak var editLocation: UITextField!
  @IBOutlet weak var gigDescription: UILabel!
  @IBOutlet weak var editDescription: UITextView!
  @IBOutlet weak var applyToGig: MaterialButton!
  @IBOutlet weak var messageButton: MaterialButton!
  @IBOutlet weak var flagButton: MaterialButton!
  @IBOutlet weak var deleteButton: MaterialButton!
  @IBOutlet weak var editButton: MaterialButton!
  @IBOutlet weak var savePostButton: MaterialButton!

  //PROPERTIES
  var gigPost: Gig!
  var request: Request?
  var appliedRef: Firebase!
  var userRef = ""
  var currentPostCategory = ""
  var postKey = ""
  
  //METHODS
  override func awakeFromNib() {
    super.awakeFromNib()
    editTitle.delegate = self
    editLocation.delegate = self
    editDescription.delegate = self
    editRate.delegate = self
    editType.delegate = self
    editTitle.hidden = true
    editLocation.hidden = true
    editDescription.hidden = true
    editRate.hidden = true
    editType.hidden = true
    editButton.hidden = true
    deleteButton.hidden = true
    savePostButton.hidden = true
    applyToGig.hidden = true
    messageButton.hidden = true
  }
  
  override func drawRect(rect: CGRect) {
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
    self.editTitle.text = gigPost.gigTitle
    self.editDescription.text = gigPost.gigDescription
    self.editRate.text = gigPost.gigRate
    self.editType.text = gigPost.gigType
    self.editLocation.text = gigPost.gigLocation
    
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
    let postRef = gigPost.gigKey
    checkIfUserIsPostAuthor(postRef)
    getCurrentPostCat(postKey)
  }
  
  func getCurrentPostCat(key: String) {
    DataService.ds.ref_gig_posts.childByAppendingPath(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
        
      } else {
        if let currentPostCategory = snapshot.value.objectForKey("gigCategory") as? String {
          if currentPostCategory != "" {
            self.currentPostCategory = currentPostCategory
          } else {
            self.currentPostCategory = ""
          }
        }
      }
    })
  }
  
  func updatePostInCategory(category: String, ref: String, post: Dictionary<String, String>) {
    DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(ref).updateChildValues(post)
  }

  func textFieldDidEndEditing(textField: UITextField) {
    if let ref = gigPost.gigKey {
      if let title = editTitle.text, let location = editLocation.text, let rate = editRate.text, let type = editType.text {
        let post: Dictionary<String, String> = [
          "gigTitle": title,
          "gigLocation": location,
          "gigRate": rate,
          "gigType": type
        ]
        
        DataService.ds.ref_gig_posts.childByAppendingPath(ref).updateChildValues(post)
        
        switch currentPostCategory {
        case "Hospitality":
          updatePostInCategory(hospitality, ref: ref, post: post)
        case "Customer Service":
          updatePostInCategory(customer, ref: ref, post: post)
        case "Artists and Musicians":
          updatePostInCategory(artists, ref: ref, post: post)
        case "TV, Media, Fashion":
          updatePostInCategory(tv, ref: ref, post: post)
        case "Office Management":
          updatePostInCategory(office, ref: ref, post: post)
        case "Child/Pet Care":
          updatePostInCategory(child, ref: ref, post: post)
        case "Construction, Contractors":
          updatePostInCategory(construction, ref: ref, post: post)
        case "Security":
          updatePostInCategory(security, ref: ref, post: post)
        case "Technology/Design":
          updatePostInCategory(tech, ref: ref, post: post)
        case "Healthcare":
          updatePostInCategory(health, ref: ref, post: post)
        case "Salon/Hair":
          updatePostInCategory(salon, ref: ref, post: post)
        case "Sales/Retail":
          updatePostInCategory(retail, ref: ref, post: post)
        case "Other":
          updatePostInCategory(other, ref: ref, post: post)
        default:
          break
        }
      }
    }
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if let ref = gigPost.gigKey {
      editDescription.text = textView.text
      if let gigDesc = editDescription.text {
        let post: Dictionary<String,String> = ["gigDescription": gigDesc]
        DataService.ds.ref_gig_posts.childByAppendingPath(ref).updateChildValues(post)
        
        switch currentPostCategory {
        case "Hospitality":
          updatePostInCategory(hospitality, ref: ref, post: post)
        case "Customer Service":
          updatePostInCategory(customer, ref: ref, post: post)
        case "Artists and Musicians":
          updatePostInCategory(artists, ref: ref, post: post)
        case "TV, Media, Fashion":
          updatePostInCategory(tv, ref: ref, post: post)
        case "Office Management":
          updatePostInCategory(office, ref: ref, post: post)
        case "Child/Pet Care":
          updatePostInCategory(child, ref: ref, post: post)
        case "Construction, Contractors":
          updatePostInCategory(construction, ref: ref, post: post)
        case "Security":
          updatePostInCategory(security, ref: ref, post: post)
        case "Technology/Design":
          updatePostInCategory(tech, ref: ref, post: post)
        case "Healthcare":
          updatePostInCategory(health, ref: ref, post: post)
        case "Salon/Hair":
          updatePostInCategory(salon, ref: ref, post: post)
        case "Sales/Retail":
          updatePostInCategory(retail, ref: ref, post: post)
        case "Other":
          updatePostInCategory(other, ref: ref, post: post)
        default:
          break
        }
      }
    }
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
  
  func checkIfUserIsPostAuthor(postRef: String) {
    DataService.ds.ref_gig_posts.childByAppendingPath(postRef).observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
      } else {
        if let userRef = snapshot.value.objectForKey("userRef") as? String {
          self.userRef = userRef
          if userRef == currentUserRef {
            self.applyToGig.hidden = true
            self.messageButton.hidden = true
            self.flagButton.hidden = true
            self.editButton.hidden = false
            self.deleteButton.hidden = false
            if let editRef = DataService.ds.ref_gig_posts.childByAppendingPath(postRef).childByAppendingPath("inEditMode") {
              editRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                  self.editTitle.hidden = true
                  self.editLocation.hidden = true
                  self.editDescription.hidden = true
                  self.editRate.hidden = true
                  self.editType.hidden = true
                  self.savePostButton.hidden = true
                } else {
                  self.gigTitle.text = ""
                  self.gigDescription.text = ""
                  self.gigRate.text = ""
                  self.gigType.text = ""
                  self.editTitle.hidden = false
                  self.editLocation.hidden = true
                  self.editDescription.hidden = false
                  self.editRate.hidden = false
                  self.editType.hidden = false
                  self.editButton.hidden = true
                  self.deleteButton.hidden = true
                  self.savePostButton.hidden = false
                }
              }, withCancelBlock: { error in
                print(error.debugDescription)
              })
            }
          } else {
            self.applyToGig.hidden = false
            self.messageButton.hidden = false
            self.flagButton.hidden = false
            self.editButton.hidden = true
            self.deleteButton.hidden = true
            self.savePostButton.hidden = true
          }
        }
      }
    }, withCancelBlock: { error in
      print(error.description)
    })
  }
  
}
