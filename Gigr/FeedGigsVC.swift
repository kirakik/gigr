//
//  FeedVC.swift
//  Gigr
//
//  Created by Kenza on 2016-03-22.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import MessageUI
import SwiftSpinner

/** CLASS EXTENSIONS **/
extension UINavigationBar {
  public override func sizeThatFits(size: CGSize) -> CGSize {
    let newSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 44)
    return newSize
  }
}

extension FeedGigsVC: FilterVCDelegate {
  func saveFilters(sender: FilterVC, city: String, category: String) {
    if city != "" {
      self.selectedCity = city
    }
    if category != "" {
      self.pickedCategory = category
    }
    populateGHTable(city, category: category)
    populateGigsTable(city, category: category)

    self.tableViewGigs.reloadData()
    self.tableViewGigHunters.reloadData()
  }
}

class FeedGigsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate {
    
  /** IB OUTLETS **/
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableViewGigs: UITableView!
  @IBOutlet weak var tableViewGigHunters: UITableView!
  @IBOutlet weak var searchBarGigs: UISearchBar!
  @IBOutlet weak var searchBarGigHunters: UISearchBar!
  @IBOutlet weak var stackViewGigs: UIStackView!
  @IBOutlet weak var stackViewGigHunters: UIStackView!
  
  
  /** PROPERTIES **/
  var pickedCategory: String?
  var selectedCity: String?
  
  /** GIG PROPERTIES **/
  var gigPosts = [Gig]()
  var appliedRef: Firebase!
  var inSearchModeGigs = false
  var postRef: Firebase!
  var filteredGigPosts = [Gig]()
  
  /** GIG HUNTER PROPERTIES **/
  var gigHunters = [GigHunter]()
  var inSearchModeGigHunters = false
  var filteredGigHunters = [GigHunter]()
  static var profilImgCache = NSCache()
  var userKey: String?

  /** VIEW FUNCTIONS **/
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Gigr"
    
    segmentedControl.selectedSegmentIndex = 0
    
    tableViewGigs.delegate = self
    tableViewGigs.dataSource = self
    tableViewGigs.emptyDataSetSource = self
    tableViewGigs.emptyDataSetDelegate = self
    tableViewGigs.tableFooterView = UIView()
    tableViewGigHunters.delegate = self
    tableViewGigHunters.dataSource = self
    tableViewGigHunters.emptyDataSetSource = self
    tableViewGigHunters.emptyDataSetDelegate = self
    tableViewGigHunters.tableFooterView = UIView()
    searchBarGigs.delegate = self
    searchBarGigHunters.delegate = self
    
    tableViewGigHunters.hidden = true
    stackViewGigHunters.hidden = true
    
    searchBarGigs.returnKeyType = UIReturnKeyType.Done
    searchBarGigHunters.returnKeyType = UIReturnKeyType.Done
    tableViewGigs.showsVerticalScrollIndicator = false
    tableViewGigHunters.showsVerticalScrollIndicator = false
    
//    segmentedControl.layer.borderColor = UIColor.lightGrayColor().CGColor
//    segmentedControl.layer.borderWidth = 1.5

    let attributes = [
      NSFontAttributeName: UIFont(name: "LemonMilk", size: 25)!,
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
    self.navigationController?.navigationBar.titleTextAttributes = attributes
  }
    
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    hideKeyboardWhenTappedAround()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tableViewGigs.estimatedRowHeight = 270
    self.tableViewGigs.rowHeight = UITableViewAutomaticDimension
    self.tableViewGigs.setNeedsLayout()
    self.tableViewGigs.layoutIfNeeded()
    
    let pickedCategory = NSUserDefaults.standardUserDefaults().objectForKey("category") as? String
    let selectedCity = NSUserDefaults.standardUserDefaults().objectForKey("location") as? String
    
    if let pickedCategory = pickedCategory {
      self.pickedCategory = pickedCategory
    }
    
    if let selectedCity = selectedCity {
      self.selectedCity = selectedCity
    }
    
    if let location = selectedCity, let category = self.pickedCategory {
      populateGigsTable(location, category: category)
      populateGHTable(location, category: category)
    }
  }
    
  /** TABLE VIEW PROTOCOL FUNCTIONS **/
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == tableViewGigs {
        if inSearchModeGigs {
          return filteredGigPosts.count
        }
        return gigPosts.count
    } else if tableView == tableViewGigHunters {
        if inSearchModeGigHunters {
          return filteredGigHunters.count
        }
        return gigHunters.count
    }
    return 1
  }
    
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var img: UIImage?
    
    if tableView == tableViewGigs {
      if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
        var post: Gig!
        
        if inSearchModeGigs {
          post = filteredGigPosts[indexPath.row]
        } else {
          post = gigPosts[indexPath.row]
        }

        cell.deleteButton.refStr = post.gigKey
        cell.deleteButton.category = post.gigCategory
        cell.applyToGig.refStr = post.gigKey
        cell.messageButton.refStr = post.gigKey
        cell.editButton.refStr = post.gigKey
        cell.savePostButton.refStr = post.gigKey
        cell.flagButton.refStr = post.gigKey
        
        if let url = post.userImg {
          img = FeedGigsVC.profilImgCache.objectForKey(url) as? UIImage
        }
        
        cell.configureCell(post, img: img)
        return cell
      } else {
        return PostCell()
      }
      
    } else if tableView == tableViewGigHunters {
      if let cellGH = tableView.dequeueReusableCellWithIdentifier("GigHunterCell") as? GigHunterCell {
        
        cellGH.request?.cancel()
        var gigHunter: GigHunter!

          if inSearchModeGigHunters {
            gigHunter = filteredGigHunters[indexPath.row]
          } else {
            gigHunter = gigHunters[indexPath.row]
          }
        
        cellGH.favoriteButton.refStr = gigHunter.userKey
        cellGH.contactButton.refStr = gigHunter.userKey
        cellGH.flagUserButton.refStr = gigHunter.userKey
        
        if let url = gigHunter.userImg {
          img = FeedGigsVC.profilImgCache.objectForKey(url) as? UIImage
        }
        
        cellGH.configureCell(gigHunter, img: img)
        return cellGH
      } else {
        return GigHunterCell()
      }

    }
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if tableView == tableViewGigs {
      return true
    }
    return false
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if tableView == tableViewGigHunters {
      let gigHunter: GigHunter!
      if inSearchModeGigHunters {
        gigHunter = filteredGigHunters[indexPath.row]
      } else {
        gigHunter = gigHunters[indexPath.row]
      }
      
      let gigHunterRef = gigHunter.userKey
      if gigHunterRef == currentUserRef {
        return 105
      } else {
        return 155
      }
    }
    
    return UITableViewAutomaticDimension
  }
  
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    self.tableViewGigs.setEditing(editing, animated: animated)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == tableViewGigHunters {
      let user: GigHunter!
      
      if inSearchModeGigHunters {
        user = filteredGigHunters[indexPath.row]
      } else {
        user = gigHunters[indexPath.row]
      }
      
      performSegueWithIdentifier("showUserProfile", sender: user)
      
    } else if tableView == tableViewGigs {
      let post: Gig!
      
      if inSearchModeGigs {
        post = filteredGigPosts[indexPath.row]
      } else {
        post = gigPosts[indexPath.row]
      }
      
      DataService.ds.ref_gig_posts.childByAppendingPath(post.gigKey).childByAppendingPath("userRef").observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          
        } else {
          if let key = snapshot.value as? String {
            let userKey = key
            self.performSegueWithIdentifier("showUserProfile", sender: userKey)
          }
        }
      })
      
    }
  }
  
  /** SEGUE FUNCTION **/
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showUserProfile" {
      if let detailVC = segue.destinationViewController as? GigHunterProfileVC {
        if let user = sender as? GigHunter {
          detailVC.ref = user.userKey
        } else if let usersKey = sender as? String {
          detailVC.ref = usersKey
        }
      }
    }
  }
  
  /** SEARCH FUNCTIONS **/
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    view.endEditing(true)
  }
    
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar == searchBarGigs {
      if searchBar.text == nil || searchBar.text == "" {
        inSearchModeGigs = false
        view.endEditing(true)
        tableViewGigs.reloadData()
      } else {
        inSearchModeGigs = true
        let range = searchBar.text!
        filteredGigPosts = gigPosts.filter({$0.gigTitle.rangeOfString(range, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil})
        tableViewGigs.reloadData()
      }
    } else if searchBar == searchBarGigHunters {
      if searchBar.text == nil || searchBar.text == "" {
        inSearchModeGigHunters = false
        view.endEditing(true)
        tableViewGigHunters.reloadData()
      } else {
        inSearchModeGigHunters = true
        let range = searchBar.text!
        filteredGigHunters = gigHunters.filter({$0.userTagline.rangeOfString(range, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil})
        tableViewGigHunters.reloadData()
      }
    }
  }
  
  /** POPOVER FUNCTION **/
  func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
    popoverPresentationController.sourceView = self.view
  }
  
  /** FUNCTIONS TO RETRIEVE INFO FROM FIREBASE **/
  func populateGigsTable(location: String, category: String) {
    if category != "Show All Categories" {
      
      switch category {
      case "Hospitality":
        populatePostsByCategory(hospitality, location: location)
      case "Customer Service":
        populatePostsByCategory(customer, location: location)
      case "Artists and Musicians":
        populatePostsByCategory(artists, location: location)
      case "TV, Media, Fashion":
        populatePostsByCategory(tv, location: location)
      case "Office Management":
        populatePostsByCategory(office, location: location)
      case "Child/Pet Care":
        populatePostsByCategory(child, location: location)
      case "Construction, Contractors":
        populatePostsByCategory(construction, location: location)
      case "Security":
        populatePostsByCategory(security, location: location)
      case "Technology/Design":
        populatePostsByCategory(tech, location: location)
      case "Healthcare":
        populatePostsByCategory(health, location: location)
      case "Salon/Hair":
        populatePostsByCategory(salon, location: location)
      case "Sales/Retail":
        populatePostsByCategory(retail, location: location)
      case "Other":
        populatePostsByCategory(other, location: location)
      default:
        break
      }
      
    } else {
      let posts = DataService.ds.ref_gig_posts
      posts.observeEventType(.Value, withBlock: { snapshot in
        
        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
          self.gigPosts = []
          
          for snap in snapshots {
            if let posts = snap.value as? Dictionary<String, AnyObject> {
              for (gigAttr, value) in posts {
                if gigAttr == "gigLocation" {
                  if let gigLocation = value as? String {
                    if gigLocation == location {
                      if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Gig(gigKey: key, dictionary: postDict)
                        self.gigPosts.insert(post, atIndex: 0)
                      }
                    }
                  }
                }
              }
            }
          }
          
          self.tableViewGigs.reloadData()
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  func populateGHTable(location: String, category: String) {
    if category != "Show All Categories" {
      
      switch category {
      case "Hospitality":
        populateUsersByCategory(hospitality, location: location)
      case "Customer Service":
        populateUsersByCategory(customer, location: location)
      case "Artists and Musicians":
        populateUsersByCategory(artists, location: location)
      case "TV, Media, Fashion":
        populateUsersByCategory(tv, location: location)
      case "Office Management":
        populateUsersByCategory(office, location: location)
      case "Child/Pet Care":
        populateUsersByCategory(child, location: location)
      case "Construction, Contractors":
        populateUsersByCategory(construction, location: location)
      case "Security":
        populateUsersByCategory(security, location: location)
      case "Technology/Design":
        populateUsersByCategory(tech, location: location)
      case "Healthcare":
        populateUsersByCategory(health, location: location)
      case "Salon/Hair":
        populateUsersByCategory(salon, location: location)
      case "Sales/Retail":
        populateUsersByCategory(retail, location: location)
      case "Other":
        populateUsersByCategory(other, location: location)
      default:
        break
      }
      
    } else {
      let users = DataService.ds.ref_users
      
      users.queryOrderedByChild("userType").queryEqualToValue("Gig Hunter").observeEventType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          
        } else {
          if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
            self.gigHunters = []
            
            for snap in snapshots {
              if let people = snap.value as? Dictionary<String, AnyObject> {
                for (userAttr, value) in people {
                  if userAttr == "city" {
                    if let userLoc = value as? String {
                      if userLoc == location {
                        if let userDict = snap.value as? Dictionary<String, AnyObject> {
                          let key = snap.key
                          let user = GigHunter(userKey: key, dictionary: userDict)
                          self.gigHunters.append(user)
                        }
                      }
                    }
                  }
                }
              }
            }
            
          }
        }
      self.tableViewGigHunters.reloadData()
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  func populatePostsByCategory(category: String, location: String) {
    let posts = DataService.ds.ref_posts_cat.childByAppendingPath(category)
    
    posts.observeEventType(.Value, withBlock: { snapshot in
      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        self.gigPosts = []
        
        for snap in snapshots {
          if let posts = snap.value as? Dictionary<String, AnyObject> {
            for (gigAttr, value) in posts {
              if gigAttr == "gigLocation" {
                if let gigLocation = value as? String {
                  if gigLocation == location {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                      let key = snap.key
                      let post = Gig(gigKey: key, dictionary: postDict)
                      self.gigPosts.insert(post, atIndex: 0)
                    }
                  }
                }
              }
            }
          }
        }
        
      }
      self.tableViewGigs.reloadData()
    }, withCancelBlock: { error in
      print(error.debugDescription)
    })
  }
  
  func populateUsersByCategory(category: String, location: String) {
    let users = DataService.ds.ref_users_cat.childByAppendingPath(category)
    
    users.queryOrderedByChild("name").observeEventType(.Value, withBlock: { snapshot in
      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        self.gigHunters = []
        
        for snap in snapshots {
          if let users = snap.value as? Dictionary<String, AnyObject> {
            for (userAttr, value) in users {
              if userAttr == "city" {
                if let userLocation = value as? String {
                  if userLocation == location {
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                      let key = snap.key
                      let user = GigHunter(userKey: key, dictionary: userDict)
                      self.gigHunters.append(user)
                    }
                  }
                }
              }
            }
          }
        }
        
      }
      self.tableViewGigHunters.reloadData()
    }, withCancelBlock: { error in
      print(error.debugDescription)
    })
  }
  
  /** FUNCTION TO DELETE FROM FIREBASE **/
  func deletePostInCategory(category: String, ref: String) {
    DataService.ds.ref_posts_cat.childByAppendingPath(category).childByAppendingPath(ref).removeValue()
  }
  
  /** IB ACTIONS **/
  @IBAction func showProfileBtnPresssed(sender: AnyObject) {
    performSegueWithIdentifier("showMyProfile", sender: nil)
  }
  
  @IBAction func selectedSegment(sender: UISegmentedControl) {
    
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      tableViewGigHunters.hidden = true
      stackViewGigHunters.hidden = true
      tableViewGigs.hidden = false
      stackViewGigs.hidden = false
      tableViewGigs.reloadData()
    case 1:
      tableViewGigs.hidden = true
      stackViewGigs.hidden = true
      tableViewGigHunters.hidden = false
      stackViewGigHunters.hidden = false
      tableViewGigHunters.reloadData()
    default:
      print("This shouldn't happen")
      break
    }
    
  }
  
  @IBAction func editButtonPressed(sender: MaterialButton) {
    if let ref = sender.refStr {
      let editRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode")
      editRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          editRef.setValue(true)
          self.tableViewGigs.reloadData()
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  @IBAction func saveButtonPressed(sender: MaterialButton) {
    if let ref = sender.refStr {
      let editRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode")
      editRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
        } else {
          SwiftSpinner.showWithDuration(1, title: "Saving your gig...")
          editRef.removeValue()
          self.tableViewGigs.reloadData()
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  
  @IBAction func deleteButtonPressed(sender: MaterialButton) {
    if let ref = sender.refStr {
      let currentUserPostRef = DataService.ds.ref_user_current.childByAppendingPath("posts").childByAppendingPath(ref)
      currentUserPostRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          // This person is not this post's author
        } else {
          let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: "Deleted posts cannot be recovered", preferredStyle: .ActionSheet)
          let okAction = UIAlertAction(title: "Yes, delete it", style: .Default) { alert in
            
            SwiftSpinner.showWithDuration(1, title: "Deleting your gig...")
            
            DataService.ds.ref_gig_posts.childByAppendingPath(ref).removeValue()
            DataService.ds.ref_user_current.childByAppendingPath("posts").childByAppendingPath(ref).removeValue()
            
            if let category = sender.category as String! {
              
              switch category {
              case "Hospitality":
                self.deletePostInCategory(hospitality, ref: ref)
              case "Customer Service":
                self.deletePostInCategory(customer, ref: ref)
              case "Artists and Musicians":
                self.deletePostInCategory(artists, ref: ref)
              case "TV, Media, Fashion":
                self.deletePostInCategory(tv, ref: ref)
              case "Office Management":
                self.deletePostInCategory(office, ref: ref)
              case "Child/Pet Care":
                self.deletePostInCategory(child, ref: ref)
              case "Construction, Contractors":
                self.deletePostInCategory(construction, ref: ref)
              case "Security":
                self.deletePostInCategory(security, ref: ref)
              case "Technology/Design":
                self.deletePostInCategory(tech, ref: ref)
              case "Healthcare":
                self.deletePostInCategory(health, ref: ref)
              case "Salon/Hair":
                self.deletePostInCategory(salon, ref: ref)
              case "Sales/Retail":
                self.deletePostInCategory(retail, ref: ref)
              case "Other":
                self.deletePostInCategory(other, ref: ref)
              default:
                break
              }
              
            }
            self.tableViewGigs.reloadData()
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
  
  @IBAction func applyToGig(sender: MaterialButton) {
    if let ref = sender.refStr {
      appliedRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("whoApplied").childByAppendingPath(currentUserRef)
      appliedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
          self.appliedRef.setValue(true)
        } else {
          self.appliedRef.removeValue()
        }
      })
    }
  }
  
  @IBAction func messagePostingUser(sender: MaterialButton!) {
    if let ref = sender.refStr {
      DataService.ds.ref_gig_posts.childByAppendingPath(ref).observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
        
        let userEmail = snapshot.value.objectForKey("userEmail") as! String
        let userRelay = "user@gigr.com"
        let emailString = NSString(format: "\(userRelay) <%@>", userEmail) as String
        let emailRecipient = [emailString]
        let postTitle = snapshot.value.objectForKey("gigTitle") as! String
        let emailSubject = "Re: \(postTitle)"
        let emailBody = "Hi, "
        
        let mailComposeViewController = self.configuredMailComposeVC(emailRecipient, subject: emailSubject, body: emailBody)
        
        if MFMailComposeViewController.canSendMail() {
          self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
          self.showSendMailErrorAlert()
        }
        
      }, withCancelBlock: { error in
        print(error.description)
      })
    }
  }
  
  @IBAction func flagBtnPressed(sender: MaterialButton) {
    if let ref = sender.refStr {
      DataService.ds.ref_gig_posts.childByAppendingPath(ref).observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
        
        let contactEmail = "kirakik@gmail.com"
        let contactRelay = "help@gigr.com"
        let emailString = NSString(format: "\(contactRelay) <%@>", contactEmail) as String
        let emailRecipient = [emailString]
        let postTitle = snapshot.value.objectForKey("gigTitle") as! String
        let postAuthor = snapshot.value.objectForKey("userRef") as! String
        let emailSubject = "FLAG POST: \(postTitle)"
        let emailBody = "This post '\(postTitle)' violates the terms and conditions of Gigr and displays offensive/deceitful and otherwise objectionable content.\n\n\n\n Post: \(ref) \n Author: \(postAuthor)"
        
        let mailComposeViewController = self.configuredMailComposeVC(emailRecipient, subject: emailSubject, body: emailBody)
        
        if MFMailComposeViewController.canSendMail() {
          self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
          self.showSendMailErrorAlert()
        }
        
      }, withCancelBlock: { error in
        print(error.description)
      })
    }
  }
  
  @IBAction func flagUserBtnPressed(sender: MaterialButton) {
    if let userRef = sender.refStr {
      DataService.ds.ref_users.childByAppendingPath(userRef).observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        let contactEmail = "kirakik@gmail.com"
        let contactRelay = "help@gigr.com"
        let emailString = NSString(format: "\(contactRelay) <%@>", contactEmail) as String
        let emailRecipient = [emailString]
        let userName = snapshot.value.objectForKey("name") as! String
        let emailSubject = "FLAG USER: \(userName)"
        let emailBody = "This user - \(userName) - violates the terms and conditions of Gigr and his profile and/or posts display offensive/deceitful and otherwise objectionable content AND/OR this user has sent abusive messages to me and/or others (in this case, please provide a screenshot of the user's message(s)). \n\n\n\n User: \(userRef)"
        
        let mailComposeViewController = self.configuredMailComposeVC(emailRecipient, subject: emailSubject, body: emailBody)
        
        if MFMailComposeViewController.canSendMail() {
          self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
          self.showSendMailErrorAlert()
        }
        
        }, withCancelBlock: { error in
          print(error.description)
      })
    }
  }
  
  @IBAction func contactBtnPressed(sender: MaterialButton) {
    if let userRef = sender.refStr {
      DataService.ds.ref_users.childByAppendingPath(userRef).observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        let userEmail = snapshot.value.objectForKey("email") as! String
        let userRelay = "user@gigr.com"
        let emailString = NSString(format: "\(userRelay) <%@>", userEmail) as String
        let emailRecipient = [emailString]
        let emailSubject = ""
        let emailBody = "Hi, "
        
        let mailComposeViewController = self.configuredMailComposeVC(emailRecipient, subject: emailSubject, body: emailBody)
        
        if MFMailComposeViewController.canSendMail() {
          self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
          self.showSendMailErrorAlert()
        }
        
      }, withCancelBlock: { error in
        print(error.description)
      })
    }
  }
  
  @IBAction func favoriteTapped(sender: FavButton) {
    if let ref = sender.refStr {
      let favoritedRef = DataService.ds.ref_user_current.childByAppendingPath("favoritedWho").childByAppendingPath(ref)
      
      favoritedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        if ref != currentUserRef {
          if let cell = self.tableViewGigHunters.dequeueReusableCellWithIdentifier("GigHunterCell") as? GigHunterCell {
            if snapshot.value is NSNull {
              cell.favoriteButton.setImage(UIImage(named: "heart-empty"), forState: .Normal)
              favoritedRef.setValue(true)
              self.tableViewGigHunters.reloadData()
            } else {
              cell.favoriteButton.setImage(UIImage(named: "heart-full"), forState: .Normal)
              favoritedRef.removeValue()
              self.tableViewGigHunters.reloadData()
            }
          }
        }
        
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  @IBAction func showFiltersButtonPressed(sender: AnyObject) {
    if let filterVC = self.storyboard?.instantiateViewControllerWithIdentifier("FilterVC") as? FilterVC {
      filterVC.delegate = self
      presentViewController(filterVC, animated: true, completion: nil)
    }
  }
  
  /** CONTACT EMAIL FUNCTIONS **/
  func configuredMailComposeVC(recipients: [String], subject: String, body: String) -> MFMailComposeViewController {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    mailComposerVC.setToRecipients(recipients)
    mailComposerVC.setSubject(subject)
    mailComposerVC.setMessageBody(body, isHTML: false)
    return mailComposerVC
  }
  
  func showSendMailErrorAlert() {
    SwiftSpinner.showWithDuration(2, title: "Message Failed", animated: false).addTapHandler({
      SwiftSpinner.hide()
    }, subtitle: "We couldn't send your message, you can throw rocks at us for failing you")
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /** EMPTY STATE FUNCTIONS **/
  func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
    return UIColor.whiteColor()
  }
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let str = "Nothing here!"
    let attrs = [NSFontAttributeName: UIFont(name: "LemonMilk", size: 20.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let str = "Looks like there's nothing yet in this category! You could make the first post in your city!"
    let attrs = [NSFontAttributeName: UIFont(name: "NotoSans", size: 14.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    return UIImage(named: "shrugempty")
  }
  
  func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
    return true
  }
  
  func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
    let str = "Post A Gig"
    let attrs = [NSFontAttributeName: UIFont(name: "LemonMilk", size: 16.0)!,
                 NSForegroundColorAttributeName: purpleButtonColor]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
    performSegueWithIdentifier("postNewGig", sender: nil)
  }
  
}
