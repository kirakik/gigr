//
//  EditProfileVC.swift
//  Gigr
//
//  Created by Kenza on 2016-03-23.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SwiftSpinner

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
  /** IB OUTLETS **/
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var fullNameField: UITextField!
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var categoryField: UITextField!
  @IBOutlet weak var jobField: UITextField!
  @IBOutlet weak var shortDescField: UITextField!
  @IBOutlet weak var skillsField: UITextField!
  @IBOutlet weak var availabilitiesField: UITextField!
  @IBOutlet weak var linkedinAccount: UITextField!
  @IBOutlet weak var categoryLabel: UIStackView!
  @IBOutlet weak var jobLabel: UIStackView!
  @IBOutlet weak var descLabel: UIStackView!
  @IBOutlet weak var skillsLabel: FormLabel!
  @IBOutlet weak var availabilitiesLabel: FormLabel!
  @IBOutlet weak var linkedinLabel: FormLabel!
  @IBOutlet weak var userTypeLabel: UILabel!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var constraintGP: NSLayoutConstraint!
  @IBOutlet weak var contraintGH: NSLayoutConstraint!
  @IBOutlet weak var registerRequiredConstraint: NSLayoutConstraint!
  @IBOutlet weak var loginRequiredConstraint: NSLayoutConstraint!
  
  /** PROPERTIES **/
  var imageSelected = false
  var imagePicker: UIImagePickerController!
  var currentUserImage = ""
  var currentUserEmail = ""
  var userPostsKeys = ""
  var pickerData = [String]()
  var pickerSelection: String!
  var pickerView = UIPickerView()
  var gigHunter: GigHunter!
  var isGigHunter = true
  var request: Request?
  var selectedCity: String?
  var selectedUserType = "Gig Hunter"
  let gpaViewController = GooglePlacesAutocomplete(
    apiKey: "AIzaSyCdPc3Qlvyn6XIO2Tky3ETnfezcOVjYQcc",
    placeType: .Cities
  )  
  
  /** VIEW FUNCTIONS **/
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "My profile"

    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    cityField.delegate = self
    gpaViewController.placeDelegate = self
    userImg.clipsToBounds = true
    
//    segmentedControl.layer.borderColor = UIColor.lightGrayColor().CGColor
//    segmentedControl.layer.borderWidth = 1.5
    
    pickerView.delegate = self
    pickerView.dataSource = self
    categoryField.inputView = pickerView
    pickerData = ["Hospitality", "Customer Service", "Artists and Musicians", "TV, Media, Fashion", "Office Management", "Child/Pet Care", "Construction, Contractors", "Security", "Technology/Design", "Healthcare", "Salon/Hair" , "Sales/Retail", "Other"]
    
    adjustToPresentingVC()
    adjustToUserType()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    userImg.layer.cornerRadius = userImg.frame.size.width / 2
    userImg.clipsToBounds = true
    
    hideKeyboardWhenTappedAround()
    let userDataKeysArr = ["email", "category", "name", "city", "userImg", "tagline", "shortDesc", "skills", "availabilities", "linkedin"]

    retrieveUserInfo()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if imageSelected == false {
      retrieveUserImg()
    }
    
  }
  
  /** PICKER VIEW PROTOCOL FUNCTIONS **/
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    pickerSelection = pickerData[row]
    categoryField.text = pickerSelection
  }
  
  /** IB ACTIONS **/
  @IBAction func selectedSegment(sender: UISegmentedControl) {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      self.selectedUserType = "Gig Hunter"
      self.categoryLabel.hidden = false
      self.categoryField.hidden = false
      self.jobLabel.hidden = false
      self.jobField.hidden = false
      self.descLabel.hidden = false
      self.shortDescField.hidden = false
      self.skillsLabel.hidden = false
      self.skillsField.hidden = false
      self.availabilitiesField.hidden = false
      self.availabilitiesLabel.hidden = false
      self.linkedinLabel.hidden = false
      self.linkedinAccount.hidden = false
      self.scrollView.scrollEnabled = true
      self.contraintGH.priority = 999
      self.constraintGP.priority = 998
      break
    case 1:
      self.selectedUserType = "Gig Poster"
      self.categoryLabel.hidden = true
      self.categoryField.hidden = true
      self.jobLabel.hidden = true
      self.jobField.hidden = true
      self.descLabel.hidden = true
      self.shortDescField.hidden = true
      self.skillsLabel.hidden = true
      self.skillsField.hidden = true
      self.availabilitiesField.hidden = true
      self.availabilitiesLabel.hidden = true
      self.linkedinLabel.hidden = true
      self.linkedinAccount.hidden = true
      self.scrollView.scrollEnabled = false
      self.contraintGH.priority = 998
      self.constraintGP.priority = 999
      break
    case 2:
      self.selectedUserType = "Gig Hunter"
      self.categoryLabel.hidden = false
      self.categoryField.hidden = false
      self.jobLabel.hidden = false
      self.jobField.hidden = false
      self.descLabel.hidden = false
      self.shortDescField.hidden = false
      self.skillsLabel.hidden = false
      self.skillsField.hidden = false
      self.availabilitiesField.hidden = false
      self.availabilitiesLabel.hidden = false
      self.linkedinLabel.hidden = false
      self.linkedinAccount.hidden = false
      self.scrollView.scrollEnabled = true
      self.contraintGH.priority = 999
      self.constraintGP.priority = 998
      break
    default:
      print("This shouldn't happen")
      break
    }
  }
  
  @IBAction func logoutBtnPressed(sender: AnyObject) {
    DataService.ds.ref_base.unauth()
    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: key_uid)
    let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC")
    UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    SwiftSpinner.showWithDuration(1, title: "Logging you out...")
  }
    
  @IBAction func selectImage(sender: UIButton) {
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func saveProfileBtnPressed(sender: UIButton) {
    if selectedUserType != "Gig Poster" {
      if let name = fullNameField.text where name != "",
        let city = cityField.text where city != "",
        let category = categoryField.text where category != "",
        let job = jobField.text where job != "",
        let shortDesc = shortDescField.text where shortDesc != "" {
        self.saveUser()
      } else {
        SwiftSpinner.showWithDuration(3, title: "Required field(s) missing", animated: false).addTapHandler({
          SwiftSpinner.hide()
        }, subtitle: "As a Gig Hunter, you need to provide your name, city, category, gig and description")
      }
    } else {
      if let name = fullNameField.text where name != "",
        let city = cityField.text where city != "" {
        self.saveUser()
        } else {
        SwiftSpinner.showWithDuration(2, title: "Required field(s) missing", animated: false).addTapHandler({
          SwiftSpinner.hide()
        }, subtitle: "Name and city are required fields")
      }
    }

  }
  
  @IBAction func deleteAccountButtonPressed(sender: MaterialButton) {
    self.deleteAccountAlert()
  }
  
  /** FUNCTIONS TO RETRIEVE INFO FROM FIREBASE **/
  func retrieveUserImg() {
    if currentUserImage != "" {
      var img: UIImage?
      if img != nil {
        self.userImg.image = img
      } else {
        request = Alamofire.request(.GET, currentUserImage).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          if err == nil {
            let img = UIImage(data: data!)!
            self.userImg.image = img
            FeedGigsVC.profilImgCache.setObject(img, forKey: self.currentUserImage)
          }
        })
      }
    }
  }
  
  func retrieveUserInfo() {
    DataService.ds.ref_user_current.observeSingleEventOfType(.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
        
      } else {
        guard let currentEmail = snapshot.value.objectForKey("email") as? String else {
          self.currentUserEmail = ""
          return
        }
        
        guard let currentUserImage = snapshot.value.objectForKey("userImg") as? String else {
          self.currentUserImage = ""
          return
        }
        
        guard let currentUserCategory = snapshot.value.objectForKey("category") as? String else {
          self.categoryField.text = ""
          return
        }
        
        guard let currentUserName = snapshot.value.objectForKey("name") as? String else {
          self.fullNameField.text = ""
          return
        }
        
        guard self.selectedCity == nil else {
          self.cityField.text = self.selectedCity
          return
        }
        
        guard let currentUserCity = snapshot.value.objectForKey("city") as? String else {
          self.cityField.text = ""
          return
        }
        
        guard let currentUserJob = snapshot.value.objectForKey("tagline") as? String else {
          self.jobField.text = ""
          return
        }
        
        guard let currentUserDesc = snapshot.value.objectForKey("shortDesc") as? String else {
          self.skillsField.text = ""
          return
        }
        
        guard let currentUserSkills = snapshot.value.objectForKey("skills") as? String else {
          self.skillsField.text = ""
          return
        }
        
        guard let currentUserAvailabilities = snapshot.value.objectForKey("availabilities") as? String else {
          self.availabilitiesField.text = ""
          return
        }

        guard let currentUserLinkedin = snapshot.value.objectForKey("linkedin") as? String else {
          self.linkedinAccount.text = ""
          return
        }
        
        self.currentUserEmail = currentEmail
        self.currentUserImage = currentUserImage
        self.categoryField.text = currentUserCategory
        self.fullNameField.text = currentUserName
        self.cityField.text = currentUserCity
        self.jobField.text = currentUserJob
        self.shortDescField.text = currentUserDesc
        self.skillsField.text = currentUserSkills
        self.availabilitiesField.text = currentUserAvailabilities
        self.linkedinAccount.text = currentUserLinkedin
      }
    }, withCancelBlock: { error in
      print(error.description)
    })
  }
  
  func adjustToUserType() {
    DataService.ds.ref_user_current.childByAppendingPath("userType").observeSingleEventOfType(.Value, withBlock: { snapshot in
      if snapshot.value is NSNull {
        
      } else {
        let userType = snapshot.value as? String
                
        if userType == "Gig Poster" {
          self.segmentedControl.selectedSegmentIndex = 1
          self.segmentedControl.sendActionsForControlEvents(.ValueChanged)
        } else if userType == "Gig Hunter" {
          self.segmentedControl.selectedSegmentIndex = 0
          self.segmentedControl.sendActionsForControlEvents(.ValueChanged)
        } else {
          self.segmentedControl.selectedSegmentIndex = 2
          self.segmentedControl.sendActionsForControlEvents(.ValueChanged)
        }
      }
    })
  }
  
  /** POSTING TO FIREBASE FUNCTIONS **/
  func postToFirebase(imgUrl: String?) {
    
    SwiftSpinner.showWithDuration(1, title: "Saving...")
    
    var user: Dictionary<String, String>
    var userCat = [String: String]()
    
    if selectedUserType == "Gig Poster" {
      user = [
        "userType": selectedUserType,
        "name": fullNameField.text!,
        "city": cityField.text!,
      ]
    } else {
      user = [
        "userType": selectedUserType,
        "name": fullNameField.text!,
        "city": cityField.text!,
        "category": categoryField.text!,
        "tagline": jobField.text!,
        "shortDesc": shortDescField.text!,
        "skills": skillsField.text!,
        "availabilities": availabilitiesField.text!,
        "linkedin": linkedinAccount.text!
      ]
    }
    
    guard currentUserImage != "" else {
      user["userImg"] = "https://imagizer.imageshack.us/v2/376x376q90/924/DmsKSf.jpg"
      userCat["userImg"] = "https://imagizer.imageshack.us/v2/376x376q90/924/DmsKSf.jpg"
      return
    }
    
    guard imgUrl != nil else {
      user["userImg"] = currentUserImage
      userCat["userImg"] = currentUserImage
      return
    }
    
    user["userImg"] = imgUrl!
    userCat["userImg"] = imgUrl!
    
    DataService.ds.ref_user_current.updateChildValues(user)
    
    //Saving users by category
    
    guard self.selectedUserType != "Gig Poster" else {
      return
    }
    
    userCat = [
      "name": fullNameField.text!,
      "email": currentUserEmail,
      "city": cityField.text!,
      "tagline": jobField.text!,
      "shortDesc": shortDescField.text!,
      "skills": skillsField.text!,
      "availabilities": availabilitiesField.text!,
      "linkedin": linkedinAccount.text!
    ]
    
    guard let category = categoryField.text else {
      return
    }
    
    switch category {
    case "Hospitality":
      updateUserInCategory(hospitality, userInfo: userCat)
      break
    case "Customer Service":
      updateUserInCategory(customer, userInfo: userCat)
      break
    case "Artists and Musicians":
      updateUserInCategory(artists, userInfo: userCat)
      break
    case "TV, Media, Fashion":
      updateUserInCategory(tv, userInfo: userCat)
      break
    case "Office Management":
      updateUserInCategory(office, userInfo: userCat)
      break
    case "Child/Pet Care":
      updateUserInCategory(child, userInfo: userCat)
      break
    case "Construction, Contractors":
      updateUserInCategory(construction, userInfo: userCat)
      break
    case "Security":
      updateUserInCategory(security, userInfo: userCat)
      break
    case "Technology/Design":
      updateUserInCategory(tech, userInfo: userCat)
      break
    case "Healthcare":
      updateUserInCategory(health, userInfo: userCat)
      break
    case "Salon/Hair":
      updateUserInCategory(salon, userInfo: userCat)
      break
    case "Sales/Retail":
      updateUserInCategory(retail, userInfo: userCat)
      break
    case "Other":
      updateUserInCategory(other, userInfo: userCat)
      break
    default:
      break
    }
  }
  
  func saveUser() {
    
    guard let img = userImg.image where imageSelected == true else {
      NSUserDefaults.standardUserDefaults().setObject("Show All Categories", forKey: "category")
      NSUserDefaults.standardUserDefaults().setObject(self.cityField.text, forKey: "location")
      postToFirebase(nil)
      return
    }
    
    let urlString = "https://post.imageshack.us/upload_api.php"
    let url = NSURL(string: urlString)!
    let imgData = UIImageJPEGRepresentation(img, 0.2)!
    let keyData = "Z5UEVH2I46d782e41f8be74f75e4f765621e5e56".dataUsingEncoding(NSUTF8StringEncoding)!
    let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
    
    Alamofire.upload(.POST, url, multipartFormData: { multipartFormData -> Void in
      multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
      multipartFormData.appendBodyPart(data: keyData, name: "key")
      multipartFormData.appendBodyPart(data: keyJSON, name: "format")
    }) { encodingResult in
      
      switch encodingResult {
      case .Success(let upload, _, _):
        upload.responseJSON(completionHandler: { response in
          guard let info = response.result.value as? Dictionary<String, AnyObject>,
            let links = info["links"] as? Dictionary<String, AnyObject>,
            let imgLink = links["image_link"] as? String
            else {
              return
          }
          
          self.postToFirebase(imgLink)
          NSUserDefaults.standardUserDefaults().setObject("Show All Categories", forKey: "category")
          NSUserDefaults.standardUserDefaults().setObject(self.cityField.text, forKey: "location")
          
        })
      case .Failure(let error):
        print(error)
      }
    }
    
    guard self.navigationController != nil else {
      self.dismissViewControllerAnimated(true, completion: nil)
      return
    }
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func updateUserInCategory(category: String, userInfo: Dictionary<String, String>) {
    DataService.ds.ref_users_cat.childByAppendingPath(category).childByAppendingPath(currentUserRef).updateChildValues(userInfo)
  }
  
  /** FUNCTIONS DELETING FROM FIREBASE **/
  func deleteAccount(email: String, pwd: String) {
    DataService.ds.ref_base.removeUser(email, password: pwd, withCompletionBlock: { error in
      
      guard error == nil else {
        print(error.debugDescription)
        SwiftSpinner.showWithDuration(2, title: "There was an error", animated: false).addTapHandler({
          SwiftSpinner.hide()
          }, subtitle: "Please check your email and password")
        return
      }
      
      
      
      DataService.ds.ref_user_current.childByAppendingPath("posts").observeEventType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          
        } else {
          guard let snapshots = snapshot.children.allObjects as? [FDataSnapshot] else {
            return
          }
          for snap in snapshots {
            guard let posts = DataService.ds.ref_gig_posts.childByAppendingPath(snap.key) else {
              return
            }
            posts.removeValue()
            
            let categories = [hospitality, customer, artists, tv, office, child, construction, security, tech, health, salon, retail, other]
            for category in categories {
              self.removePostsInCategory(category, postRef: snap.key)
              self.removeUserInCategory(category)
            }
          }
        }
      })
      
      DataService.ds.ref_user_current.removeValue()
      DataService.ds.ref_base.unauth()
      
      NSUserDefaults.standardUserDefaults().setValue(nil, forKey: key_uid)
      
      self.view.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
      
      if let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as? LoginVC {
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
      }
      
    })
  }
  
  func deleteAccountAlert() {
    var emailInput: UITextField?
    var passwordInput: UITextField?
    let textEntryPrompt = UIAlertController(title: "Enter your password and email", message: "Please enter your password and email to confirm", preferredStyle: .Alert)
    
    textEntryPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
      
      textField.placeholder = "Email"
      textField.autocorrectionType = .No
      textField.keyboardType = .EmailAddress
      emailInput = textField
      
    })
    
    textEntryPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
      
      textField.placeholder = "Password"
      textField.secureTextEntry = true
      textField.autocorrectionType = .No
      passwordInput = textField
      
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
      
      guard let email = emailInput!.text where email != "",
        let password = passwordInput!.text where password != ""
        else {
          SwiftSpinner.showWithDuration(2, title: "Empty Field(s)", animated: false).addTapHandler({
            SwiftSpinner.hide()
            }, subtitle: "Password and email required")
          return
      }
      
      self.deleteAccount(email, pwd: password)
    })
    
    textEntryPrompt.addAction(cancelAction)
    textEntryPrompt.addAction(okAction)
    
    presentViewController(textEntryPrompt, animated: true, completion: nil)
  }
  
  func removePostsInCategory(category: String, postRef: String) {
    if let post = DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(postRef) {
      post.removeValue()
    }
  }
  
  func removeUserInCategory(category: String) {
    if let user = DataService.ds.ref_users_cat.childByAppendingPath(category).childByAppendingPath(currentUserRef) {
      user.removeValue()
    }
  }
  
  /** GPA FUNCTIONS **/
  override func placeSelected(place: Place) {
    super.placeSelected(place)
    guard selectedCity == nil else {
      self.cityField.text = selectedCity
      return
    }
    selectedCity = place.description
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    presentViewController(gpaViewController, animated: true, completion: nil)
  }
  
  /** TEXT VIEW FUNCTIONS **/
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == "e.g. Needs to be available 3 nights a week and have experience" {
      textView.text = ""
      textView.textColor = UIColor.darkGrayColor()
    }
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    guard textView.text.isEmpty else {
      textView.textColor = UIColor.darkGrayColor()
      return
    }
    textView.text = "e.g. Needs to be available 3 nights a week and have experience"
    textView.textColor = veryLightGrayColor
  }
  
  /** IMAGE PICKER FUNCTION **/
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage,
    editingInfo: [String : AnyObject]?) {
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    userImg.image = image
    imageSelected = true
  }
  
  /** OTHER FUNCTIONS **/
  func adjustToPresentingVC() {
    let n: Int! = self.navigationController?.viewControllers.count
    let presentingVC = self.navigationController?.viewControllers[n-2]
    let feedGigsVC = self.storyboard?.instantiateViewControllerWithIdentifier("FeedGigsVC")
    
    guard presentingVC?.nibName == feedGigsVC?.nibName else {
      userTypeLabel.hidden = false
      segmentedControl.hidden = false
      loginRequiredConstraint.priority = 998
      registerRequiredConstraint.priority = 999
      return
    }
    
    userTypeLabel.hidden = true
    segmentedControl.hidden = true
    categoryField.userInteractionEnabled = false
    loginRequiredConstraint.priority = 999
    registerRequiredConstraint.priority = 998
    
  }
  
}
