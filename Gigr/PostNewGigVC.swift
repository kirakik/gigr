//
//  PostNewGigVC.swift
//  Gigr
//
//  Created by Kenza on 2016-03-23.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import SwiftSpinner

class PostNewGigVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
  //OUTLETS
  @IBOutlet weak var categoryField: UITextField!
  @IBOutlet weak var gigTitleField: UITextField!
  @IBOutlet weak var gigDescField: UITextView!
  @IBOutlet weak var gigLocationField: UITextField!
  @IBOutlet weak var gigRateField: UITextField!
  @IBOutlet weak var gigTypeField: UITextField!
    
  //PROPERTIES
  var currentUserImg = ""
  var currentUserEmail = ""
  var currentUserName = ""
  var selectedCity: String?
  var pickerCategoryData = [String]()
  var pickerTypeData = [String]()
  var pickerCatSelection: String!
  var pickerTypeSelection: String!
  var postRef: Firebase!
  var pickerCategory = UIPickerView()
  var pickerType = UIPickerView()
  let gpaViewController = GooglePlacesAutocomplete(
    apiKey: "AIzaSyCdPc3Qlvyn6XIO2Tky3ETnfezcOVjYQcc",
    placeType: .Cities
  )
  var todaysDate = ""
  
  //VIEW METHODS
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    gigDescField.delegate = self
    gigLocationField.delegate = self
    gpaViewController.placeDelegate = self
    
    self.title = "New Post"
        
    DataService.ds.ref_user_current.observeSingleEventOfType(.Value, withBlock: { snapshot in
      if let currentUserImg = snapshot.value.objectForKey("userImg") as? String {
        self.currentUserImg = currentUserImg
      } else {
        self.currentUserImg = "https://imagizer.imageshack.us/v2/376x376q90/924/DmsKSf.jpg"
      }
      if let currentUserEmail = snapshot.value.objectForKey("email") as? String {
        self.currentUserEmail = currentUserEmail
      } else {
        self.currentUserEmail = ""
      }
      if let currentUserName = snapshot.value.objectForKey("name") as? String {
        self.currentUserName = currentUserName
      } else {
        self.currentUserName = ""
      }
    }, withCancelBlock: { error in
      print(error.description)
    })
    
    pickerCategory.delegate = self
    pickerCategory.dataSource = self
    pickerCategory.tag = 1
    pickerType.delegate = self
    pickerType.dataSource = self
    pickerType.tag = 2
    categoryField.inputView = pickerCategory
    gigTypeField.inputView = pickerType

    pickerCategoryData = ["Hospitality", "Customer Service", "Artists and Musicians", "TV, Media, Fashion", "Office Management", "Child/Pet Care", "Construction, Contractors", "Security", "Technology/Design", "Healthcare", "Salon/Hair" , "Sales/Retail", "Other"]
    pickerTypeData = ["Contract", "Full Time", "Part Time", "Seasonal", "Internship"]
    
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: date)
    let todaysDate = "\(components.year)/\(components.month)/\(components.day)"
    self.todaysDate = todaysDate
  }
  
  //GPA METHODS
  override func placeSelected(place: Place) {
    super.placeSelected(place)
    selectedCity = place.description
    if selectedCity != nil {
      self.gigLocationField.text = selectedCity
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  //ACTIONS
  @IBAction func backBtnPressed(sender: UIButton) {
    dismissViewControllerAnimated(false, completion: nil)
  }
    
  @IBAction func postGigBtnPressed(sender: UIButton) {
    if let title = gigTitleField.text where title != "",
      let desc = gigDescField.text where desc != "",
      let location = gigLocationField.text where location != "",
      let category = categoryField.text where category != "" {
      SwiftSpinner.showWithDuration(1, title: "Posting your gig...")
      postToFirebase()
      self.navigationController?.popViewControllerAnimated(true)
    } else {
      SwiftSpinner.showWithDuration(2, title: "Required Field(s) missing", animated: false).addTapHandler({
        SwiftSpinner.hide()
      }, subtitle: "Check to see what you forgot!")
    }
  }
    
  //SYNCING WITH BACKEND
  func postToFirebase() {
    let gigPost: Dictionary<String, AnyObject> = [
      "datePosted": todaysDate,
      "gigCategory": categoryField.text!,
      "gigTitle": gigTitleField.text!,
      "gigDescription": gigDescField.text!,
      "gigLocation": gigLocationField.text!,
      "gigType": gigTypeField.text!,
      "gigRate": gigRateField.text!,
      "userImg": currentUserImg,
      "userEmail": currentUserEmail,
      "userRef": currentUserRef,
      "author": currentUserName
    ]
        
    let firebasePost = DataService.ds.ref_gig_posts.childByAutoId()
    firebasePost.setValue(gigPost)
    let gigUrl = "\(firebasePost)"
    let gigRef = gigUrl.substringWithRange(Range<String.Index>(gigUrl.startIndex.advancedBy(36)..<gigUrl.endIndex))
    postRef = DataService.ds.ref_user_current.childByAppendingPath("posts").childByAppendingPath(gigRef)
    postRef.setValue(true)
    
    // Post gig in appropriate category
    let gigPostCat: Dictionary<String, AnyObject> = [
      "datePosted": todaysDate,
      "gigTitle": gigTitleField.text!,
      "gigDescription": gigDescField.text!,
      "gigLocation": gigLocationField.text!,
      "gigType": gigTypeField.text!,
      "gigRate": gigRateField.text!,
      "userImg": currentUserImg,
      "userEmail": currentUserEmail,
      "userRef": currentUserRef,
      "author": currentUserName
    ]
    
    if let pickedCategory = categoryField.text {
      switch pickedCategory {
      case "Hospitality":
        postGigInCategory(hospitality, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Customer Service":
        postGigInCategory(customer, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Artists and Musicians":
        postGigInCategory(artists, gigRef: gigRef, gigPostCat: gigPostCat)
      case "TV, Media, Fashion":
        postGigInCategory(tv, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Office Management":
        postGigInCategory(office, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Child/Pet Care":
        postGigInCategory(child, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Construction, Contractors":
        postGigInCategory(construction, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Security":
        postGigInCategory(security, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Technology/Design":
        postGigInCategory(tech, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Healthcare":
        postGigInCategory(health, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Salon/Hair":
        postGigInCategory(salon, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Sales/Retail":
        postGigInCategory(retail, gigRef: gigRef, gigPostCat: gigPostCat)
      case "Other":
        postGigInCategory(other, gigRef: gigRef, gigPostCat: gigPostCat)
      default:
        break
      }
    }
  }
  
  func postGigInCategory(category: String, gigRef: String, gigPostCat: Dictionary<String, AnyObject>) {
    let firebasePost = DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(gigRef)
    firebasePost.setValue(gigPostCat)
  }

  //TEXT VIEW/FIELD DELEGATE METHODS
  func textFieldDidBeginEditing(textField: UITextField) {
    presentViewController(gpaViewController, animated: true, completion: nil)
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.textColor == veryLightGrayColor {
      if textView.text == "e.g. Needs to be available 3 nights a week and have experience" {
        textView.text = ""
      }
    textView.textColor = UIColor.darkGrayColor()
    }
  }
    
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "e.g. Needs to be available 3 nights a week and have experience"
      textView.textColor = veryLightGrayColor
    }
  }
  
  //PICKER VIEW METHODS
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    if pickerView.tag == 2 {
      return 1
    } else {
      return 1
    }
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 2 {
      return pickerTypeData.count
    } else {
      return pickerCategoryData.count
    }
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 2 {
      return pickerTypeData[row]
    } else {
      return pickerCategoryData[row]
    }
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 2 {
      pickerTypeSelection = pickerTypeData[row]
      gigTypeField.text = pickerTypeSelection
    } else {
      pickerCatSelection = pickerCategoryData[row]
      categoryField.text = pickerCatSelection
    }
  }
  
}
