//
//  GigHunterProfileVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-12.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import MessageUI
import SwiftSpinner

class GigHunterProfileVC: UIViewController, MFMailComposeViewControllerDelegate {
  
  //OUTLETS
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var userJobTitle: UILabel!
  @IBOutlet weak var userCity: UILabel!
  @IBOutlet weak var userDesc: UILabel!
  @IBOutlet weak var userSkills: UILabel!
  @IBOutlet weak var userAvailabilities: UILabel!
  @IBOutlet weak var userLinkedin: UIButton!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var contactButton: MaterialButton!
  @IBOutlet weak var flagUserButton: MaterialButton!
  @IBOutlet weak var showUserPosts: UIButton!
  @IBOutlet weak var showUserPostsArrow: UIImageView!
  @IBOutlet weak var skillsSV: UIStackView!
  @IBOutlet weak var availabilitiesSV: UIStackView!
  @IBOutlet weak var linkedinSV: UIStackView!
  @IBOutlet weak var userHasNoPostsConstraint: NSLayoutConstraint!
  @IBOutlet weak var userHasPostsConstraint: NSLayoutConstraint!
  @IBOutlet weak var userIsGH: NSLayoutConstraint!
  @IBOutlet weak var userIsNotGH: NSLayoutConstraint!
  
  //PROPERTIES
  var request: Request?
  var ref = ""
  var favoritedRef: Firebase!
  var currentUserImage = ""
  
  //VIEW METHODS
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "PROFILE"
    if self.ref != "" {
      favoritedRef = DataService.ds.ref_user_current.childByAppendingPath("favoritedWho").childByAppendingPath(ref)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    retrieveUserImg()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    userImg.layer.cornerRadius = userImg.frame.size.width / 2
    userImg.clipsToBounds = true
    retrieveUserInfo()
    checkIfUserHasPosts()
    checkIfUserWasFavorited()
  }
  
  //SEGUES
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showUserPosts" {
      if let detailVC = segue.destinationViewController as? UserPostsVC {
        detailVC.userKey = ref
        if let userName = self.userName.text {
          detailVC.userName = userName
        } else {
          detailVC.userKey = "This user"
        }
      }
    }
  }
  
  //RETRIEVING FROM FIREBASE
  
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
    if let userRef = DataService.ds.ref_users.childByAppendingPath(ref) {
      userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if snapshot.value is NSNull {
        } else {
          if let currentUserName = snapshot.value.objectForKey("name") as? String {
            self.userName.text = currentUserName
            let userNameUpper = currentUserName.uppercaseString
            self.showUserPosts.setTitle("\(userNameUpper)'S POSTS", forState: .Normal)
          } else {
            self.userName.text = ""
          }
          if let userType = snapshot.value.objectForKey("userType") as? String {
            if userType != "Gig Poster" {
              self.userIsGH.priority = 999
              self.userIsNotGH.priority = 998
              if let currentUserJob = snapshot.value.objectForKey("tagline") as? String {
                self.userJobTitle.text = currentUserJob
              } else {
                self.userJobTitle.text = ""
              }
            } else {
              self.userJobTitle.text = "Employer"
              self.userIsGH.priority = 998
              self.userIsNotGH.priority = 999
              self.userDesc.hidden = true
              self.skillsSV.hidden  = true
              self.availabilitiesSV.hidden = true
              self.linkedinSV.hidden = true
              self.favoriteButton.hidden = false
              self.contactButton.hidden = false
              self.flagUserButton.hidden = false
            }
          }
          if let currentUserCity = snapshot.value.objectForKey("city") as? String {
            if currentUserCity != "" {
              self.userCity.text = currentUserCity
            } else {
              self.userCity.text = ""
            }
          } else {
            self.userCity.text = ""
          }
          if let currentUserDesc = snapshot.value.objectForKey("shortDesc") as? String {
            self.userDesc.text = currentUserDesc
          } else {
            self.userDesc.text = ""
          }
          if let currentUserSkills = snapshot.value.objectForKey("skills") as? String {
            if currentUserSkills != "" {
              self.userSkills.text = currentUserSkills
            } else {
              self.userSkills.text = "/"
            }
          } else {
            self.userSkills.text = "/"
          }
          if let currentUserAvailabilities = snapshot.value.objectForKey("availabilities") as? String {
            if currentUserAvailabilities != "" {
              self.userAvailabilities.text = currentUserAvailabilities
            } else {
              self.userAvailabilities.text = "/"
            }
          } else {
            self.userAvailabilities.text = "/"
          }
          if let currentUserLinkedin = snapshot.value.objectForKey("linkedin") as? String {
            if currentUserLinkedin != "http://linkedin.com/in/" {
              self.userLinkedin.setTitle(currentUserLinkedin, forState: .Normal)
            } else {
              self.userLinkedin.setTitle("/", forState: .Normal)
            }
          } else {
            self.userLinkedin.setTitle("/", forState: .Normal)
          }
          if let currentUserImage = snapshot.value.objectForKey("userImg") as? String {
            if currentUserImage != "" {
              self.currentUserImage = currentUserImage
            } else {
              self.currentUserImage = ""
            }
          } else {
            self.currentUserImage = ""
          }
        }
      }, withCancelBlock: { error in
        print(error.debugDescription)
      })
    }
  }
  
  func checkIfUserHasPosts() {
    DataService.ds.ref_users.childByAppendingPath(ref).childByAppendingPath("posts").observeSingleEventOfType(.Value, withBlock: { snapshot in
      if self.ref != currentUserRef {
        if snapshot.value is NSNull {
          self.showUserPosts.hidden = true
          self.showUserPostsArrow.hidden = true
          self.userHasPostsConstraint.priority = 998
          self.userHasNoPostsConstraint.priority = 999
        } else {
          self.showUserPosts.hidden = false
          self.showUserPostsArrow.hidden = false
          self.userHasPostsConstraint.priority = 999
          self.userHasNoPostsConstraint.priority = 998
        }
      }
    })
  }
  
  func checkIfUserWasFavorited() {
    favoritedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      if self.ref != currentUserRef {
        self.favoriteButton.hidden = false
        self.contactButton.hidden = false
        self.flagUserButton.hidden = false
        if snapshot.value is NSNull {
          // We haven't liked this specific person
          self.favoriteButton.setImage(UIImage(named: "heart-empty"), forState: .Normal)
        } else {
          self.favoriteButton.setImage(UIImage(named: "heart-full"), forState: .Normal)
        }
      } else {
        self.favoriteButton.hidden = true
        self.contactButton.hidden = true
        self.flagUserButton.hidden = true
        self.showUserPosts.hidden = true
        self.showUserPostsArrow.hidden = true
      }
    }, withCancelBlock: { error in
      print(error.debugDescription)
    })
  }
  
  //CONTACT EMAIL METHODS
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
  
  //ACTIONS
  @IBAction func contactBtnPressed(sender: MaterialButton) {
    if ref != "" {
      DataService.ds.ref_users.childByAppendingPath(ref).observeSingleEventOfType(.Value, withBlock: { snapshot in
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

  @IBAction func favoriteBtnPressed(sender: AnyObject) {
    favoritedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if self.ref != "" {
          if snapshot.value is NSNull {
            // We haven't liked this specific post
            self.favoriteButton.setImage(UIImage(named: "heart-full"), forState: .Normal)
            self.favoritedRef.setValue(true)
          } else {
            self.favoriteButton.setImage(UIImage(named: "heart-empty"), forState: .Normal)
            self.favoritedRef.removeValue()
          }
        }
    }, withCancelBlock: { error in
      print(error.debugDescription)
    })
  }

  @IBAction func flagUserBtnPressed(sender: AnyObject) {
    if ref != "" {
      DataService.ds.ref_users.childByAppendingPath(ref).observeSingleEventOfType(.Value, withBlock: { snapshot in
        let contactEmail = "kirakik@gmail.com"
        let contactRelay = "help@gigr.com"
        let emailString = NSString(format: "\(contactRelay) <%@>", contactEmail) as String
        let emailRecipient = [emailString]
        let userName = snapshot.value.objectForKey("name") as! String
        let emailSubject = "FLAG USER: \(userName)"
        let emailBody = "This user - \(userName) - violates the terms and conditions of Gigr and his profile and/or posts display offensive/deceitful and otherwise objectionable content AND/OR this user has sent abusive messages to me and/or others (in this case, please provide a screenshot of the user's message(s)). \n\n\n\n User: \(self.ref)"
        
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
  
  @IBAction func linkedinBtnPressed(sender: AnyObject) {
    if userLinkedin.titleLabel?.text != "/" {
      let linkedin = "\(userLinkedin.titleLabel!.text!)"
      UIApplication.sharedApplication().openURL(NSURL(string: linkedin)!)
    }
  }

  @IBAction func showUserPosts(sender: AnyObject) {
    performSegueWithIdentifier("showUserPosts", sender: nil)
  }
  
}
