//
//  UserPostsVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-27.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import MessageUI
import SwiftSpinner

class UserPostsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate {
  
  /** IB OUTLETS **/
  @IBOutlet weak var tableView: UITableView!
  
  /** PROPERTIES **/
  var gigPosts = [Gig]()
  var appliedRef: Firebase!
  var postRef: Firebase!
  var userKey = ""
  var userName = ""

  /** VIEW FUNCTIONS **/
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = ""
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
    
    if userKey != "" {
      populateGigPosts(userKey)
    }
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    hideKeyboardWhenTappedAround()
    tableView.reloadData()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tableView.estimatedRowHeight = 270
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.setNeedsLayout()
    self.tableView.layoutIfNeeded()
    
  }
  
  /** TABLE VIEW PROTOCOL FUNCTIONS **/
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gigPosts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var img: UIImage?
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("UserPostCell") as? UserPostCell {
      let post = gigPosts[indexPath.row]
      
      cell.applyToGig.refStr = "\(post.gigKey)"
      cell.messageButton.refStr = "\(post.gigKey)"
      
      if let url = post.userImg {
        img = FeedGigsVC.profilImgCache.objectForKey(url) as? UIImage
      }
      
      cell.configureCell(post, img: img)
      
      return cell
    } else {
      return UserPostCell()
    }
    
  }
//  
//  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//    return true
//  }
  
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    self.tableView.setEditing(editing, animated: animated)
  }

  func populateGigPosts(userKey: String) {
    if let currentUserPosts = DataService.ds.ref_users.childByAppendingPath(userKey).childByAppendingPath("posts") {
      
      currentUserPosts.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if let snaps = snapshot.children.allObjects as? [FDataSnapshot] {
          self.gigPosts = []
          
          for snap in snaps {
            let numberOfUserPosts = snaps.count
            let currentUserSnaps = snap.key
            if let posts = DataService.ds.ref_gig_posts {
              posts.observeEventType(.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                  for snapPost in snapshots {
                    if let firebaseSnaps = snapPost.key {
                      if currentUserSnaps == firebaseSnaps {
                        if let postDict = snapPost.value as? Dictionary<String, AnyObject> {
                          let key = snapPost.key
                          let post = Gig(gigKey: key, dictionary: postDict)
                          let numberOfPostsDisplayed = self.gigPosts.count
                          if numberOfPostsDisplayed < numberOfUserPosts {
                            self.gigPosts.append(post)
                          } else if numberOfPostsDisplayed == numberOfUserPosts {
                          } else {
                            self.gigPosts.popLast()
                            self.tableView.reloadData()
                          }
                        }
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
  
  @IBAction func applyToGig(sender: MaterialButton) {
    if let ref = sender.refStr {
      appliedRef = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("whoApplied").childByAppendingPath(currentUserRef)
      appliedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("UserPostCell") as? UserPostCell {
          if snapshot.value is NSNull {
            cell.applyToGig.setTitle("I'M INTERESTED", forState: UIControlState.Normal)
            cell.applyToGig.backgroundColor = purpleButtonColor
            self.appliedRef.setValue(true)
          } else {
            cell.applyToGig.setTitle("YOU APPLIED", forState: UIControlState.Normal)
            cell.applyToGig.backgroundColor = greenButtonColor
            self.appliedRef.removeValue()
          }
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
    let str = "\(userName) hasn't posted any gigs yet!"
    let attrs = [NSFontAttributeName: UIFont(name: "NotoSans", size: 14.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    return UIImage(named: "shrugempty")
  }
  
  func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
    return true
  }


}
