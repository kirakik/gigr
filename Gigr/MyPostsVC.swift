//
//  MyPostsVC.swift
//  Gigr
//
//  Created by Kenza on 2016-04-09.
//  Copyright © 2016 Kenza. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class MyPostsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

  //OUTLETS
  @IBOutlet weak var collectionView: UICollectionView!
  
  //PROPERTIES
  var myPosts = [Gig]()
  var ref = ""
  
  //VIEW METHODS
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.emptyDataSetSource = self
    collectionView.emptyDataSetDelegate = self
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    collectionView.allowsMultipleSelection = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.reloadData()
    removeEditModes()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    populateCurrentUserPosts()
  }
  
  //COLLECTION VIEW METHODS
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return myPosts.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyPostCell", forIndexPath: indexPath) as? MyPostCell {
      let post = myPosts[indexPath.row]
      ref = post.gigKey
      cell.configureCell(post)
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let post = myPosts[indexPath.row]
    performSegueWithIdentifier("showMyPost", sender: post)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(90, 90)
  }

  //SEGUES
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMyPost" {
      if let detailVC = segue.destinationViewController as? MyPostDetailVC {
        if let post = sender as? Gig {
          detailVC.detailPost = post
          detailVC.ref = post.gigKey
          let gigRefCat = "\(post.gigRefCat)"
          detailVC.refCat = gigRefCat
          detailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
          detailVC.navigationItem.leftItemsSupplementBackButton = true
        }
      }
    }
  }
  
  //FIREBASE METHODS
  func populateCurrentUserPosts() {
    if let currentUserPosts = DataService.ds.ref_user_current.childByAppendingPath("posts") {
      currentUserPosts.observeSingleEventOfType(.Value, withBlock: { snapshot in
        if let snaps = snapshot.children.allObjects as? [FDataSnapshot] {
          self.myPosts = []
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
                          let numberOfPostsDisplayed = self.myPosts.count
                          if numberOfPostsDisplayed < numberOfUserPosts {
                            self.myPosts.append(post)
                          } else if numberOfPostsDisplayed == numberOfUserPosts {
                          } else {
                            self.myPosts.popLast()
                            self.collectionView.reloadData()
                          }
                        }
                      }
                    }
                  }
                }
                self.collectionView.reloadData()
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
  
  func removeEditModes() {
    if ref != "" {
      if let inEditMode = DataService.ds.ref_gig_posts.childByAppendingPath(ref).childByAppendingPath("inEditMode") {
        inEditMode.observeSingleEventOfType(.Value, withBlock: { snapshot in
          if snapshot.value is NSNull {
            
          } else {
            inEditMode.removeValue()
          }
        })
      }
    }
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
    let str = "Looks like you haven't posted anything yet! Post your first gig and find your gig hunter soulmates!"
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
