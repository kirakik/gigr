//
//  FilterVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-20.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit

extension UIViewController: GooglePlacesAutocompleteDelegate {
  public func placeSelected(place: Place) {
    
    place.getDetails { details in
    }
  }
  
  public func placeViewClosed() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

class FilterVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
  
  //OUTLETS
  @IBOutlet weak var locationField: UITextField!
  @IBOutlet weak var categoryField: UITextField!
  
  //PROPERTIES
  let kTopOffset: CGFloat = 50.0
  var categoriesArray = [String]()
  var pickerView = UIPickerView()
  var pickedCategory: String!
  var selectedCity: String?
  let gpaViewController = GooglePlacesAutocomplete(
    apiKey: "AIzaSyCdPc3Qlvyn6XIO2Tky3ETnfezcOVjYQcc",
    placeType: .Cities
  )
  weak var delegate: FilterVCDelegate?
  var dismissViewUp: CGRect?
  var dismissViewDown: CGRect?
  
  //VIEW METHODS
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapExit = UITapGestureRecognizer(target: self, action: #selector(FilterVC.handleTap(_:)))
    self.view.addGestureRecognizer(tapExit)
    let dismissViewUp = CGRectMake(0, 0, self.view.bounds.height, 120)
    self.dismissViewUp = dismissViewUp
    let dismissViewDown = CGRectMake(0, 305, self.view.bounds.width, self.view.bounds.height - 120)
    self.dismissViewDown = dismissViewDown
    locationField.delegate = self
    categoriesArray = ["Show All Categories", "Hospitality", "Customer Service", "Artists and Musicians", "TV, Media, Fashion", "Office Management", "Child/Pet Care", "Construction, Contractors", "Security", "Technology/Design", "Healthcare", "Salon/Hair" , "Sales/Retail", "Other"]
    pickerView.delegate = self
    pickerView.dataSource = self
    gpaViewController.placeDelegate = self
    categoryField.inputView = pickerView
    pickedCategory = categoriesArray[0]
    self.categoryField.text = NSUserDefaults.standardUserDefaults().objectForKey("category") as? String
    self.locationField.text = NSUserDefaults.standardUserDefaults().objectForKey("location") as? String
    self.commonInit()
  }
  
  override func viewDidAppear(animated: Bool) {
    let row = NSUserDefaults.standardUserDefaults().integerForKey("picker")
    self.pickerView.selectRow(row, inComponent: 0, animated: true)
  }
  
  //GPA METHODS
  func textFieldDidBeginEditing(textField: UITextField) {
    presentViewController(gpaViewController, animated: true, completion: nil)
  }
  
  override func placeSelected(place: Place) {
    super.placeSelected(place)
    selectedCity = place.description
    if selectedCity != nil {
      self.locationField.text = selectedCity
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  //PICKER VIEW METHODS
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoriesArray.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categoriesArray[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    pickedCategory = categoriesArray[row]
    categoryField.text = pickedCategory
    NSUserDefaults.standardUserDefaults().setInteger(row, forKey: "picker")
  }

  @IBAction func saveFilters(sender: MaterialButton) {
    NSUserDefaults.standardUserDefaults().setObject(categoryField.text, forKey: "category")
    NSUserDefaults.standardUserDefaults().setObject(locationField.text, forKey: "location")
    if let location = locationField.text where location != "", let category = categoryField.text where category != "" {
      delegate?.saveFilters(self, city: location, category: category)
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //POPOVER METHODS
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.commonInit()
  }
  
  func commonInit() {
    self.modalPresentationStyle = .Custom
    self.transitioningDelegate = self
  }

  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    if presented == self {
      return PresentationVC(presentedViewController: presented, presentingViewController: presenting)
    }
    return nil
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if presented == self {
      return PresentationAnimVC(isPresenting: true)
    } else {
      return nil
    }
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if dismissed == self {
      return PresentationAnimVC(isPresenting: false)
    } else {
      return nil
    }
  }
  
  //TAP GESTURE RECOGNIZER METHOD
  func handleTap(gestureRecognizer: UITapGestureRecognizer) {
    let locationInView: CGPoint = gestureRecognizer.locationInView(self.view)
    if CGRectContainsPoint(self.dismissViewUp!, locationInView) {
      dismissViewControllerAnimated(true, completion: nil)
    }
    if CGRectContainsPoint(self.dismissViewDown!, locationInView) {
      dismissViewControllerAnimated(true, completion: nil)
    }
    
  }
  
}

// DELEGATES
protocol FilterVCDelegate: class {
  func saveFilters(sender: FilterVC, city: String, category: String)
}
