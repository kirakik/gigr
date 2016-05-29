//
//  ViewController.swift
//  Gigr
//
//  Created by Kenza on 2016-03-21.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftSpinner
import MessageUI

class LoginVC: UIViewController, MFMailComposeViewControllerDelegate {
    
  /** IB OUTLETS **/
  @IBOutlet weak var orLabel: UILabel!
  @IBOutlet weak var facebookLoginBtn: MaterialButton!
  @IBOutlet weak var emailLoginBtn: MaterialButton!
  @IBOutlet weak var registerLoginSV: UIStackView!
  @IBOutlet weak var loginOption: UIButton!
  @IBOutlet weak var registerOption: UIButton!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var loginButton: MaterialButton!
  @IBOutlet weak var registerButton: MaterialButton!
  @IBOutlet weak var emailSV: UIStackView!
  @IBOutlet weak var reenterEmailSV: UIStackView!
  @IBOutlet weak var reenteremailField: MaterialTextField!
  @IBOutlet weak var passwordSV: UIStackView!
  @IBOutlet weak var reenterpasswordSV: UIStackView!
  @IBOutlet weak var reenterPasswordField: MaterialTextField!
  @IBOutlet weak var infoImg: UIImageView!
  @IBOutlet weak var agreementsLabel: UILabel!
  @IBOutlet weak var forgotPaswordButton: UIButton!
  @IBOutlet weak var privacyPolicyButton: UIButton!
  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
  @IBOutlet weak var passwordRegisterConstraint: NSLayoutConstraint!
  @IBOutlet weak var passwordLoginConstraint: NSLayoutConstraint!
  @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
  
  /** PROPERTIES **/
  var activeField: UITextField?
  var animEngine: AnimationEngine!
  let borderLogin = CALayer()
  let borderRegister = CALayer()

  /** VIEW METHODS **/
  override func viewDidLoad() {
    super.viewDidLoad()
    self.hideKeyboardWhenTappedAround()
    self.animEngine = AnimationEngine(constraints: [stackViewTopConstraint])

    emailField.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    reenteremailField.attributedPlaceholder = NSAttributedString(string:"Re-enter email", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    passwordField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    reenterPasswordField.attributedPlaceholder = NSAttributedString(string:"Re-enter Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    
    setLoginSelected()

    registerLoginSV.hidden = true
    loginButton.hidden = true
    registerButton.hidden = true
    emailSV.hidden = true
    passwordSV.hidden = true
    forgotPaswordButton.hidden = true
    backButton.hidden = true
    
    contentViewHeight.constant = 400
  }
    
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if NSUserDefaults.standardUserDefaults().valueForKey(key_uid) != nil {
      self.performSegueWithIdentifier(segue_login, sender: nil)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if NSUserDefaults.standardUserDefaults().valueForKey(key_uid) != nil {
      self.view.hidden = true
    }
  }

  /** IB ACTIONS **/
  @IBAction func emailLoginBtnPressed(sender: AnyObject) {
    facebookLoginBtn.hidden = true
    orLabel.hidden = true
    emailLoginBtn.hidden = true
    registerLoginSV.hidden = false
    loginButton.hidden = false
    emailSV.hidden = false
    passwordSV.hidden = false
    forgotPaswordButton.hidden = false
    backButton.hidden = false
    self.animEngine.animateOnScreen(1)
  }
  
  @IBAction func fbBntPressed(sender: UIButton) {
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
      
      guard facebookError == nil || facebookResult != nil else {
        SwiftSpinner.showWithDuration(1, title: "Facebook Login Failed", animated: false).addTapHandler({
          SwiftSpinner.hide()
        })
        return
      }
      
      let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
      
      DataService.ds.ref_base.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
        
        guard error == nil else {
          SwiftSpinner.showWithDuration(1, title: "Facebook Login Failed", animated: false).addTapHandler({
            SwiftSpinner.hide()
          })
          return
        }
        
        let user: Dictionary<String, String> = [
          "provider": authData.provider!,
          "name": authData.providerData["displayName"] as! String,
          "email": authData.providerData["email"] as! String,
          "userImg": authData.providerData["profileImageURL"] as! String
        ]
        
        DataService.ds.createFirebaseUser(authData.uid, user: user)
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: key_uid)
        self.performSegueWithIdentifier(segue_registered, sender: nil)
      })
    }
  }
  
  @IBAction func attemptLogin(sender: UIButton) {
    SwiftSpinner.show("Logging you in...")
    
    guard let email = emailField.text where email != "" else {
      SwiftSpinner.showWithDuration(2, title: "Empty Email", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "You need to enter an email")
      return
    }
    
    guard let pwd = passwordField.text where pwd != "" else {
      SwiftSpinner.showWithDuration(2, title: "Empty Password", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "You need to enter a password")
      return
    }
    
    DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: { error, authData in
      if error != nil {
        guard error.code != status_account_nonexist else {
          SwiftSpinner.showWithDuration(1, title: "This account doesn't exist", animated: false).addTapHandler({
            SwiftSpinner.hide()
            }, subtitle: "Please check your email or tap 'register'")
          return
        }
        
        guard let errorCode = FAuthenticationError(rawValue: error.code) else {
          SwiftSpinner.showWithDuration(2, title: "There was an error", animated: false).addTapHandler({
            SwiftSpinner.hide()
            }, subtitle: "Check your internet connection")
          return
        }
        
        switch(errorCode) {
        case .InvalidEmail:
          SwiftSpinner.showWithDuration(1, title: "Your email is invalid", animated: false)
        case .InvalidPassword:
          SwiftSpinner.showWithDuration(1, title: "Wrong Password", animated: false)
        default:
          break
        }
      } else {
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: key_uid)
        
        SwiftSpinner.hide({
          self.performSegueWithIdentifier(segue_login, sender: nil)
        })
      }
    })
  }
  
  @IBAction func attemptRegister(sender: AnyObject) {
    SwiftSpinner.showWithDuration(2, title: "Creating your account...")
    
    guard let email = emailField.text where email != "" else {
      SwiftSpinner.showWithDuration(2, title: "Empty Email Field", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "You need to enter an email")
      return
    }
    
    guard let pwd = passwordField.text where pwd != "" else {
      SwiftSpinner.showWithDuration(2, title: "Empty Password Field", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "You need to enter a password")
      return
    }
    
    guard email == reenteremailField.text else {
      SwiftSpinner.showWithDuration(2, title: "Emails don't match", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "Please check your email entry")
      return
    }
    
    guard pwd == reenterPasswordField.text else {
      SwiftSpinner.showWithDuration(2, title: "Passwords don't match", animated: false).addTapHandler({
        SwiftSpinner.hide()
        }, subtitle: "Please check your password entry")
      return
    }
    
    DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: { error, authData in
      
      if error != nil && error.code != status_account_nonexist {
        if let errorCode = FAuthenticationError(rawValue: error.code) {
          switch(errorCode) {
          case .InvalidEmail:
            SwiftSpinner.showWithDuration(1, title: "Your email is invalid", animated: false)
          case .InvalidPassword:
            SwiftSpinner.showWithDuration(1, title: "Wrong Password", animated: false)
          default:
            break
          }
        }
        SwiftSpinner.showWithDuration(2, title: "There was an error", animated: false).addTapHandler({
          SwiftSpinner.hide()
          }, subtitle: "Check your internet connection")
      } else if error == nil {
        SwiftSpinner.showWithDuration(1, title: "This account already exists", animated: false).addTapHandler({
          SwiftSpinner.hide()
          }, subtitle: "Please login instead")
      }
      
      guard error.code == status_account_nonexist else {
        return
      }
      
      DataService.ds.ref_base.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
        
        guard error == nil else {
          SwiftSpinner.showWithDuration(2, title: "There was an error", animated: false).addTapHandler({
            SwiftSpinner.hide()
            }, subtitle: "Please try again later")
          return
        }
        
        DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: { error, authData in
          
          let user = ["provider": authData.provider!, "email": email]
          DataService.ds.createFirebaseUser(authData.uid, user: user)
          NSUserDefaults.standardUserDefaults().setValue(result[key_uid], forKey: key_uid)
          self.performSegueWithIdentifier(segue_registered, sender: nil)
        })
      })
    })
  }
  
  @IBAction func backLogoPressed(sender: AnyObject) {
    contentViewHeight.constant = 400
    facebookLoginBtn.hidden = false
    orLabel.hidden = false
    emailLoginBtn.hidden = false
    registerLoginSV.hidden = true
    loginButton.hidden = true
    emailSV.hidden = true
    passwordSV.hidden = true
    forgotPaswordButton.hidden = true
    backButton.hidden = true
    reenterEmailSV.hidden = true
    reenterpasswordSV.hidden = true
    agreementsLabel.hidden = true
    termsButton.hidden = true
    infoImg.hidden = true
    privacyPolicyButton.hidden = true
    registerButton.hidden = true
    setLoginSelected()
  }
  
  @IBAction func loginOptionPressed(sender: AnyObject) {
    setLoginSelected()
    loginButton.hidden = false
    forgotPaswordButton.hidden = false
  }
  
  @IBAction func registerOptionPressed(sender: AnyObject) {
    setRegisterSelected()
    registerButton.hidden = false
  }
  
  
  @IBAction func forgotPasswordBtnPressed(sender: AnyObject) {
    var emailInput: UITextField?
    let textEntryPrompt = UIAlertController(title: "Password Reset", message: "Please enter your email", preferredStyle: .Alert)
    
    textEntryPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
      textField.placeholder = "Email"
      textField.autocorrectionType = .No
      textField.keyboardType = .EmailAddress
      emailInput = textField
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
      
      guard let email = emailInput!.text where email != "" else {
        SwiftSpinner.showWithDuration(2, title: "Missing Email", animated: false).addTapHandler({
          SwiftSpinner.hide()
          }, subtitle: "You need to enter your email")
        return
      }
      
      DataService.ds.ref_base.resetPasswordForUser(email, withCompletionBlock: { error in
        
        guard error == nil else {
          SwiftSpinner.showWithDuration(2, title: "There was an error", animated: false).addTapHandler({
            SwiftSpinner.hide()
            }, subtitle: "We were not able to reset your password")
          return
        }
        
        SwiftSpinner.showWithDuration(2, title: "Password was reset", animated: false).addTapHandler({
          SwiftSpinner.hide()
          }, subtitle: "Check your inbox")
      })
    })
    
    textEntryPrompt.addAction(cancelAction)
    textEntryPrompt.addAction(okAction)
    presentViewController(textEntryPrompt, animated: true, completion: nil)
  }
  
  @IBAction func helpButnPressed(sender: AnyObject) {
    let contactEmail = "kirakik@gmail.com"
    let contactRelay = "help@gigr.com"
    let emailString = NSString(format: "\(contactRelay) <%@>", contactEmail) as String
    let emailRecipient = [emailString]
    let emailSubject = "Need help with Gigr"
    let emailBody = "(Please explain the issue you are facing)"
    let mailComposeViewController = self.configuredMailComposeVC(emailRecipient, subject: emailSubject, body: emailBody)
    
    if MFMailComposeViewController.canSendMail() {
      self.presentViewController(mailComposeViewController, animated: true, completion: nil)
    } else {
      self.showSendMailErrorAlert()
    }
  }
  
  func setRegisterSelected() {
    let width = CGFloat(2.5)
    
    borderRegister.borderColor = UIColor.whiteColor().CGColor
    borderRegister.frame = CGRect(x: 0, y: registerOption.frame.size.height - width, width: registerOption.frame.size.width + 160, height: registerOption.frame.size.height)
    borderRegister.borderWidth = width
    registerOption.layer.addSublayer(borderRegister)
    registerOption.layer.masksToBounds = true
    
    guard loginOption.layer.superlayer == nil else {
      borderLogin.removeFromSuperlayer()
      return
    }
    
    contentViewHeight.constant = 500
    reenterEmailSV.hidden = false
    reenterpasswordSV.hidden = false
    passwordLoginConstraint.priority = 998
    passwordRegisterConstraint.priority = 999
    infoImg.hidden = false
    agreementsLabel.hidden = false
    termsButton.hidden = false
    privacyPolicyButton.hidden = false
    loginButton.hidden = true
    forgotPaswordButton.hidden = true
  }
  
  func setLoginSelected() {
    let width = CGFloat(2.5)
    
    borderLogin.borderColor = UIColor.whiteColor().CGColor
    borderLogin.frame = CGRect(x: 0, y: loginOption.frame.size.height - width, width: loginOption.frame.size.width + 160, height: loginOption.frame.size.height)
    borderLogin.borderWidth = width
    loginOption.layer.addSublayer(borderLogin)
    loginOption.layer.masksToBounds = true
  
    guard registerOption.layer.superlayer == nil else {
      borderRegister.removeFromSuperlayer()
      return
    }
    
    contentViewHeight.constant = 400
    reenterEmailSV.hidden = true
    reenterpasswordSV.hidden = true
    passwordLoginConstraint.priority = 999
    passwordRegisterConstraint.priority = 998
    agreementsLabel.hidden = true
    termsButton.hidden = true
    infoImg.hidden = true
    privacyPolicyButton.hidden = true
    registerButton.hidden = true
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

}

