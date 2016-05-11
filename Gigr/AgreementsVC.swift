//
//  AgreementsVC.swift
//  Gigr
//
//  Created by Kenza on 2016-05-03.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

class AgreementsVC: UIViewController, UITextViewDelegate {
  
  /** IB OUTLETS **/
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var privacyTV: UITextView!
  @IBOutlet weak var termsTV: UITextView!

  /** FUNCTIONS **/
  override func viewDidLoad() {
    super.viewDidLoad()
    segmentedControl.selectedSegmentIndex = 0
//    segmentedControl.layer.borderColor = UIColor.lightGrayColor().CGColor
//    segmentedControl.layer.borderWidth = 1.5
  }
  
  /** IB ACTIONS **/
  @IBAction func segmentSelected(sender: AnyObject) {
    
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      privacyTV.hidden = true
      termsTV.hidden = false
    case 1:
      privacyTV.hidden = false
      termsTV.hidden = true
    default:
      print("This shouldn't happen")
      break
    }

  }
  
  @IBAction func dismissBtnPressed(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
