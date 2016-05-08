//
//  FavoritedPeopleVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-29.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import DZNEmptyDataSet

class FavoritedPeopleVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

  @IBOutlet weak var tableView: UITableView!

  var favoritedPeople = [GigHunter]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Favorites"
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    populateFavoritedPeople()
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favoritedPeople.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("FavoritedPeople") as? WhoAppliedCell {
      let user = favoritedPeople[indexPath.row]
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
    let user = favoritedPeople[indexPath.row]
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


  func populateFavoritedPeople() {
    DataService.ds.ref_user_current.childByAppendingPath("favoritedWho").observeEventType(.Value, withBlock: { snapshot in
      self.favoritedPeople = []
      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        for snap in snapshots {
          let usersKeys = snap.key
          if let usersRef = DataService.ds.ref_users {
            usersRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
              if let userSnapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snapshot in userSnapshots {
                  if snapshot.key == usersKeys {
                    if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                      let key = snapshot.key
                      let user = GigHunter(userKey: key, dictionary: userDict)
                      self.favoritedPeople.insert(user, atIndex: 0)
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
  
  //EMPTY STATE METHODS
  func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
    return UIColor.whiteColor()
  }
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let str = "Nothing here!"
    let attrs = [NSFontAttributeName: UIFont(name: "LemonMilk", size: 20.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let str = "Looks like you haven't favorited anyone yet!"
    let attrs = [NSFontAttributeName: UIFont(name: "NotoSans", size: 14.0)!]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    return UIImage(named: "brokenheart")
  }
  
}
