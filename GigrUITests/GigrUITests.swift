//
//  GigrUITests.swift
//  GigrUITests
//
//  Created by Kenza on 2016-04-05.
//  Copyright © 2016 Kenza. All rights reserved.
//

import XCTest

class GigrUITests: XCTestCase {
        
  override func setUp() {
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
        
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication().launch()

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
    
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testRegisterScreen() {
//    let app = XCUIApplication()
//    app.textFields["Email"].tap()
//    app.textFields["Email"]
//    app.secureTextFields["Password"].tap()
//    app.secureTextFields["Password"]
//    app.buttons["LOG IN / REGISTER"].tap()
  }
    
  func testEditProfileAfterRegisteringScreen() {
//    let app = XCUIApplication()
//    let elementsQuery = app.scrollViews.otherElements
//    let fullNameTextField = elementsQuery.textFields["Full Name"]
//    fullNameTextField.tap()
//    elementsQuery.buttons["+"].tap()
//    app.tables.buttons["Camera Roll"].tap()
//    app.collectionViews["PhotosGridView"].cells["Photo, Landscape, April 03, 6:00 PM"].tap()
//    fullNameTextField.tap()
//    elementsQuery.textFields["Full Name"]
//    elementsQuery.textFields["Role (what do you do - 1-2 words)"].tap()
//    elementsQuery.textFields["Role (what do you do - 1-2 words)"]
//    elementsQuery.childrenMatchingType(.TextView).element.tap()
//    elementsQuery.childrenMatchingType(.TextView).element
//    elementsQuery.buttons["SAVE"].tap()
    
  }
    
  func testEditProfile() {
    let app = XCUIApplication()
    app.buttons["LOOKING"].tap()
    app.buttons["EDIT MY PROFILE"].tap()
        
    let elementsQuery = app.scrollViews.otherElements
    elementsQuery.textFields["Role (what do you do - 1-2 words)"].tap()
    elementsQuery.textFields["Role (what do you do - 1-2 words)"]
    elementsQuery.buttons["SAVE"].tap()
  }
    
  func testPostNewGig() {
    let app = XCUIApplication()
    app.buttons["POST NEW GIG"].tap()
        
    let elementsQuery = app.scrollViews.otherElements
    elementsQuery.textFields["Post Title"].tap()
    elementsQuery.textFields["Post Title"]
        
    let textView = elementsQuery.childrenMatchingType(.TextView).element
    textView.tap()
    textView.tap()
    elementsQuery.childrenMatchingType(.TextView).element
        
    let locationEGNewYorkTextField = elementsQuery.textFields["Location (e.g. New York)"]
    locationEGNewYorkTextField.tap()
    locationEGNewYorkTextField.tap()
    elementsQuery.textFields["Location (e.g. New York)"]
    
    let datesEGApril15thContinuousTextField = elementsQuery.textFields["Dates (e.g. April 15th, continuous...)"]
    datesEGApril15thContinuousTextField.tap()
    datesEGApril15thContinuousTextField.tap()
    elementsQuery.textFields["Dates (e.g. April 15th, continuous...)"]
        
    let gigRateEG15Hr200DayTextField = elementsQuery.textFields["Gig rate (e.g. $15/hr, $200/day)"]
    gigRateEG15Hr200DayTextField.tap()
    gigRateEG15Hr200DayTextField.tap()
    elementsQuery.textFields["Gig rate (e.g. $15/hr, $200/day)"]
    elementsQuery.buttons["POST GIG"].tap()
    
  }
    
  func testSearchGig() {
    let app = XCUIApplication()
    app.searchFields["Search"].tap()
    app.searchFields["Search"]
    app.buttons["Done"].tap()
    app.typeText("bab\n")
    
  }
    
  func testSearchGigHunters() {
    let app = XCUIApplication()
    app.buttons["LOOKING"].tap()
    app.searchFields["Search"].tap()
    app.searchFields["Search"]
    app.buttons["Done"].tap()
    app.typeText("bar\n")
    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
  }
    
  func testMessageGig() {
    let app = XCUIApplication()
    app.buttons["HIRING"].tap()
    
    let tablesQuery = app.tables
    tablesQuery.cells.containingType(.StaticText, identifier:"I'm looking for the perfect flower to complement me and make me happy").buttons["MESSAGE"].tap()
    tablesQuery.staticTexts["I'm looking for the perfect flower to complement me and make me happy"].tap()
        
  }
    
  func testAlternatingViews() {
    let app = XCUIApplication()
    let hiringButton = app.buttons["HIRING"]
    hiringButton.tap()
        
    let lookingButton = app.buttons["LOOKING"]
    lookingButton.tap()
    hiringButton.tap()
    lookingButton.tap()
    hiringButton.tap()
  }
    
}
