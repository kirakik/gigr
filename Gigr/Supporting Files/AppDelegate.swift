//
//  AppDelegate.swift
//  Gigr
//
//  Created by Kenza on 2016-03-21.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    setUpFirebasePersistence()
    setUpNavBar()
    setUpKeyboard()
    setUpSegmentedControls()
    setUpPushNotifications()
    setUpDynamicShortcuts(application)
    
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func setUpFirebasePersistence() {
    Firebase.defaultConfig().persistenceEnabled = true
  }
  
  func setUpPushNotifications() {
    //    Batch.startWithAPIKey("DEV571538A410CD24D9809889DF3EB")
    //    let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
    //    let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
    //    application.registerUserNotificationSettings(pushNotificationSettings)
    //    application.registerForRemoteNotifications()
  }
  
  //  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
  //  }
  //
  //  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
  //    print(error)
  //  }
  
  //  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
  //    application.dismissNotifications()
  //  }
  
  func setUpKeyboard() {
    IQKeyboardManager.sharedManager().enable = true
    IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(PostNewGigVC)
    IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(LoginVC)
  }
  
  func setUpNavBar() {
    let barAppearance = UIBarButtonItem.appearance()
    barAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
  }
  
  func setUpSegmentedControls() {
    let attr = NSDictionary(object: UIFont(name: "LemonMilk", size: 12.0)!, forKey: NSFontAttributeName)
    UISegmentedControl.appearance().setTitleTextAttributes(attr as? [NSObject : AnyObject] , forState: .Normal)
    UISegmentedControl.appearance().layer.borderColor = UIColor.lightGrayColor().CGColor
    UISegmentedControl.appearance().layer.borderWidth = 1.5
  }
  
  func setUpDynamicShortcuts(application: UIApplication) {
    if let shortcutItems = application.shortcutItems where shortcutItems.isEmpty {
      let dynamicShortcut = UIMutableApplicationShortcutItem(type: "MyPosts", localizedTitle: "My Posts", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.Contact), userInfo: nil)
      application.shortcutItems = [dynamicShortcut]
    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
    
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Kenny.Gigr" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("Gigr", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason

      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
        
    return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
  
//  func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
//    let handledShortCutItem = handleShortcutItemPressed(shortcutItem)
//    completionHandler(handledShortCutItem)
//  }
  
//  func handleShortcutItemPressed(shortcutItem: UIApplicationShortcutItem) -> Bool {
//    var handled = false
//    let rootVC = window?.rootViewController
//    rootVC?.performSegueWithIdentifier(segue_login, sender: nil)
//
//    if let feedGigsVC = rootVC?.storyboard?.instantiateViewControllerWithIdentifier("FeedGigsVC") {
//      print(feedGigsVC)
//      feedGigsVC.performSegueWithIdentifier("postNewGig", sender: nil)
//    }
//    let uid = NSUserDefaults.standardUserDefaults().valueForKey(key_uid) as? String
//    if uid != "" {
//      if let rootVC = window?.rootViewController as? UINavigationController {
//        print(rootVC)
//        if let feedGigsVC = rootVC.viewControllers.first as? FeedGigsVC {
//  
//          if shortcutItem.type == "Post" {
//            feedGigsVC!.performSegueWithIdentifier("postNewGig", sender: nil)
//            handled = true
//          } else if shortcutItem.type == "MyPosts" {
//            feedGigsVC!.performSegueWithIdentifier("showMyPosts", sender: nil)
//            handled = true
//          }
//          
//        }
//      }
//    }
//    return handled
//  }

}

