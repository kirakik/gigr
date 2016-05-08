//
//  MyPostDetailVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-10.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import DZNEmptyDataSet
import SwiftSpinner

class MyPostDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
  //OUTLETS
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var postTitle: UILabel!
  @IBOutlet weak var postLocation: UILabel!
  @IBOutlet weak var postDesc: UILabel!
  @IBOutlet weak var postRate: UILabel!
  @IBOutlet weak var postType: UILabel!
  @IBOutlet weak var editTitle: UITextField!
  @IBOutlet weak var editLocation: UITextField!
  @IBOutlet weak var editDesc: UITextView!
  @IBOutlet weak var editRate: UITextField!
  @IBOutlet weak var editType: UITextField!
  @IBOutlet weak var editButton: MaterialButton!
  @IBOutlet weak var deleteButton: MaterialButton!
  @IBOutlet weak var doneButton: MaterialButton!
  
  //PROPERTIES
  var detailPost: Gig?
  var ref = ""
  var refCat = ""
  var currentPostCategory = ""
  var peopleWhoApplied = [GigHunter]()
  var selectedCity: String?
  let gpaViewController = GooglePlacesAutocomplete(
    apiKey: "AIzaSyCdPc3Qlvyn6XIO2Tky3ETnfezcOVjYQcc",
    placeType: .Cities
  )
  
  //VIEW METHODS
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Your Gig"
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    editTitle.delegate = self
    editLocation.delegate = self
    editDesc.delegate = self
    editRate.delegate = self
    editType.delegate = self
    gpaViewController.placeDelegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updatePostData()
    populateWhoApplied()
    adjustToEditMode()
  }

  //TABLE VIEW METHODS
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peopleWhoApplied.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("WhoAppliedCell") as? WhoAppliedCell {
      let user = peopleWhoApplied[indexPath.row]
      cell.request?.cancel()
      var img: UIImage?
      if let url = user.userImg {
        img = FeedGigsVC.profilImgCache.objectForKey(url) as? UIImage
      }
      cell.configureCell(user, img: img)
      return cell
    }
    return WhoAppliedCell()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let user = peopleWhoApplied[indexPath.row]
    performSegueWithIdentifier("showUserProfile", sender: user)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showUserProfile" {
      if let detailVC = segue.destinationViewController as? GigHunterProfileVC {
        if let user = sender as? GigHunter {
          detailVC.ref = user.userKey
        }
      }
    }
  }
  
  //GPA METHOD
  override func placeSelected(place: Place) {
    super.placeSelected(place)
    selectedCity = place.description
    if selectedCity != nil {
      self.editLocation.text = selectedCity
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    if textField == editLocation {
      presentViewController(gpaViewController, animated: true, completion: nil)
    }
  }
  
  //RETRIEVING FROM FIREBASE
  func updatePostData() {
    if let currentPost = DataService.ds.ref_gig_posts.childByAppendingPath(ref) {
      currentPost.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          
        } else {
          if let currentPostTitle = snapshot.value.objectForKey("gigTitle") as? String {
            self.postTitle.text = currentPostTitle
            self.editTitle.text = currentPostTitle
          } else {
            self.postTitle.text = ""
            self.editTitle.text = ""
          }
          if let currentPostLocation = snapshot.value.objectForKey("gigLocation") as? String {
            self.postLocation.text = currentPostLocation
            self.editLocation.text = currentPostLocation
          } else {
            self.postLocation.text = ""
            self.editLocation.text = ""
          }
          if let currentPostCategory = snapshot.value.objectForKey("gigCategory") as? String {
            self.currentPostCategory = currentPostCategory
          } else {
            self.currentPostCategory = ""
          }
          if let currentPostDescription = snapshot.value.objectForKey("gigDescription") as? String {
            self.postDesc.text = currentPostDescription
            self.editDesc.text = currentPostDescription
          } else {
            self.postDesc.text = ""
            self.editDesc.text = ""
          }
          if let currentPostRate = snapshot.value.objectForKey("gigRate") as? String {
            self.postRate.text = currentPostRate
            self.editRate.text = currentPostRate
          } else {
            self.postRate.text = ""
            self.editRate.text = ""
          }
          if let currentPostType = snapshot.value.objectForKey("gigType") as? String {
            self.postType.text = currentPostType
            self.editType.text = currentPostType
          } else {
            self.postType.text = ""
            self.editType.text = ""
          }
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  func populateWhoApplied() {
    if let usersWhoApplied = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("whoApplied") {
      usersWhoApplied.observeSingleEventOfType(.Value, withBlock: { snapshot in
        self.peopleWhoApplied = []
        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
          for snap in snapshots {
            let usersKeys = snap.key
            if let usersRef = DataService.ds.ref_users {
              usersRef.observeEventType(.Value, withBlock: { snapshot in
                if let userSnapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                  for snapshot in userSnapshots {
                    if snapshot.key == usersKeys {
                      if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        let key = snapshot.key
                        let user = GigHunter(userKey: key, dictionary: userDict)
                        self.peopleWhoApplied.insert(user, atIndex: 0)
                      }
                    }
                  }
                }
                self.tableView.reloadData()
              }, withCancelBlock: { error in
                print(error.debugDescription)
              })
            }
          }
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  func adjustToEditMode() {
    if let editModeRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode") {
      editModeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          self.postTitle.hidden = false
          self.postLocation.hidden = false
          self.postDesc.hidden = false
          self.postRate.hidden = false
          self.postType.hidden = false
          self.editTitle.hidden = true
          self.editLocation.hidden = true
          self.editDesc.hidden = true
          self.editRate.hidden = true
          self.editType.hidden = true
          self.editButton.hidden = false
          self.deleteButton.hidden = false
          self.doneButton.hidden = true
        } else {
          self.postTitle.hidden = true
          self.postLocation.hidden = true
          self.postDesc.hidden = true
          self.postRate.hidden = true
          self.postType.hidden = true
          self.editTitle.hidden = false
          self.editLocation.hidden = false
          self.editDesc.hidden = false
          self.editRate.hidden = false
          self.editType.hidden = false
          self.doneButton.hidden = false
          self.editButton.hidden = true
          self.deleteButton.hidden = true
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  //SAVING TO FIREBASE
  func savePostInCategory(category: String, post: Dictionary<String, String>) {
    DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(ref).updateChildValues(post)
  }
  
  func saveToFirebase() {
    if let title = editTitle.text, let location = editLocation.text, let gigDesc = editDesc.text, let rate = editRate.text, let type = editType.text {
      let post: Dictionary<String, String> = [
        "gigTitle": title,
        "gigLocation": location,
        "gigDescription": gigDesc,
        "gigRate": rate,
        "gigType": type,
      ]
      DataService.ds.ref_gig_posts.childByAppendingPath(ref).updateChildValues(post)
      switch currentPostCategory {
      case "Hospitality":
        savePostInCategory(hospitality, post: post)
      case "Customer Service":
        savePostInCategory(customer, post: post)
      case "Artists and Musicians":
        savePostInCategory(artists, post: post)
      case "TV, Media, Fashion":
        savePostInCategory(tv, post: post)
      case "Office Management":
        savePostInCategory(office, post: post)
      case "Child/Pet Care":
        savePostInCategory(child, post: post)
      case "Construction, Contractors":
        savePostInCategory(construction, post: post)
      case "Security":
        savePostInCategory(security, post: post)
      case "Technology/Design":
        savePostInCategory(tech, post: post)
      case "Healthcare":
        savePostInCategory(health, post: post)
      case "Salon/Hair":
        savePostInCategory(salon, post: post)
      case "Sales/Retail":
        savePostInCategory(retail, post: post)
      case "Other":
        savePostInCategory(other, post: post)
      default:
        break
      }
    
    }
  }
  
  //DELETING FROM FIREBASE
  func deletePostInCategory(category: String) {
    DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(self.ref).removeValue()
  }
  
  //ACTIONS
  @IBAction func deleteButtonPressed(sender: MaterialButton) {
    if let currentUserPostRef = DataService.ds.ref_user_current.childByAppendingPath("posts").childByAppendingPath(ref) {
      currentUserPostRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          // This person is not this post's author
        } else {
          let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: "Deleted posts cannot be recovered", preferredStyle: .ActionSheet)
          let okAction = UIAlertAction(title: "Yes, delete it", style: .Default) { alert in
            SwiftSpinner.showWithDuration(1, title: "Deleting your gig...")
            DataService.ds.ref_gig_posts.childByAppendingPath(self.ref).removeValue()
            DataService.ds.ref_user_current.childByAppendingPath("posts").childByAppendingPath(self.ref).removeValue()
            switch self.currentPostCategory {
            case "Hospitality":
              self.deletePostInCategory(hospitality)
            case "Customer Service":
              self.deletePostInCategory(customer)
            case "Artists and Musicians":
              self.deletePostInCategory(artists)
            case "TV, Media, Fashion":
              self.deletePostInCategory(tv)
            case "Office Management":
              self.deletePostInCategory(office)
            case "Child/Pet Care":
              self.deletePostInCategory(child)
            case "Construction, Contractors":
              self.deletePostInCategory(construction)
            case "Security":
              self.deletePostInCategory(security)
            case "Technology/Design":
              self.deletePostInCategory(tech)
            case "Healthcare":
              self.deletePostInCategory(health)
            case "Salon/Hair":
              self.deletePostInCategory(salon)
            case "Sales/Retail":
              self.deletePostInCategory(retail)
            case "Other":
              self.deletePostInCategory(other)
            default:
              break
            }
            self.navigationController?.popViewControllerAnimated(true)
          }
          let noAction = UIAlertAction(title: "No, don't delete it", style: .Default) { alert in
          }
          alert.addAction(okAction)
          alert.addAction(noAction)
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }

  @IBAction func editButtonPressed(sender: MaterialButton) {
    if let editModeRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode") {
      editModeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          self.postTitle.hidden = true
          self.postLocation.hidden = true
          self.postDesc.hidden = true
          self.postRate.hidden = true
          self.postType.hidden = true
          self.editTitle.hidden = false
          self.editLocation.hidden = false
          self.editDesc.hidden = false
          self.editRate.hidden = false
          self.editType.hidden = false
          self.editButton.hidden = true
          self.deleteButton.hidden = true
          self.doneButton.hidden = false
          editModeRef.setValue(true)
        } else {
          
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  @IBAction func doneButtonPressed(sender: MaterialButton) {
    if let editModeRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode") {
      editModeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
        } else {
          self.postTitle.hidden = false
          self.postLocation.hidden = false
          self.postDesc.hidden = false
          self.postRate.hidden = false
          self.postType.hidden = false
          self.editTitle.hidden = true
          self.editLocation.hidden = true
          self.editDesc.hidden = true
          self.editRate.hidden = true
          self.editType.hidden = true
          self.editButton.hidden = false
          self.deleteButton.hidden = false
          self.doneButton.hidden = true
          SwiftSpinner.showWithDuration(1, title: "Saving your gig...")
          self.saveToFirebase()
          self.updatePostData()
          editModeRef.removeValue()
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  //EMPTY STATE METHODS
  func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
    return UIColor.whiteColor()
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let str = "No one has applied to your post yet"
    let attrs = [NSFontAttributeName: UIFont(name: "NotoSans-Italic", size: 14.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
}
