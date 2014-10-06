//
//  ViewController.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/24/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var behindTintImageView: UIImageView!
    
    let dateFormater = NSDateFormatter()
    var composeButton: UIBarButtonItem?
    var refreshControl: UIRefreshControl?
    var showFeed = true
    
    override func loadView() {
        super.loadView()
        
        let rect = CGRectMake(0,0,20,20);
        UIGraphicsBeginImageContext(rect.size);
        UIImage(named: "compose.png").drawInRect(rect)
        let resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let imageData = UIImagePNGRepresentation(resized);
        let newComposeImage = UIImage(data: imageData)
        
        composeButton = UIBarButtonItem(image: newComposeImage, style: .Plain, target: self, action: "didTapCompose:")
        
        TwitterClient.client.feedViewController = self
        
        dateFormater.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.parentViewController!.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.parentViewController!.navigationItem.rightBarButtonItem = composeButton
    }
    
    func didTapCompose(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("composeViewSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.addSubview(refreshControl!)
        feedTableView.estimatedRowHeight = 100
        feedTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeViewSegue" {
            let composeViewController = segue.destinationViewController as ComposeViewController
            composeViewController.feedViewControllerDelegate = self
            UIView.animateWithDuration(0.5, animations: {
                self.behindTintImageView.alpha = 1
            })
        } else if segue.identifier == "tweetViewSegue" {
            let tweetViewController = segue.destinationViewController as TweetViewController
            let cellRow = feedTableView.indexPathForCell(sender as StatusTableViewCell)?.row
            tweetViewController.status = TwitterClient.client.statuses![cellRow!]
            tweetViewController.row = cellRow
            tweetViewController.feedViewControllerDelegate = self
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCellWithIdentifier("statusCell") as StatusTableViewCell
        var status: Status
        if showFeed {
            status = TwitterClient.client.statuses![indexPath.row]
        } else {
            status = TwitterClient.client.mentions![indexPath.row]
        }
        
        let tap = NamedUITapGestureRecognizer(target: self, action: "didTapProfileImageView:")
        tap.username = status.username
        
        cell.userImageView.addGestureRecognizer(tap)
        cell.userImageView.userInteractionEnabled = true
        
        cell.status = status
        return cell
    }
    
    func didTapProfileImageView(sender: NamedUITapGestureRecognizer) {
        TwitterClient.client.getUserProfile(sender.username!)
        let parent = self.parentViewController as HomeViewController
        let profileViewController = parent.viewControllers![0] as ProfileViewController
        
        parent.activeViewController = profileViewController
        parent.title = sender.username!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFeed && TwitterClient.client.statuses?.count > 0 {
            return TwitterClient.client.statuses!.count
        } else if !showFeed && TwitterClient.client.mentions?.count > 0 {
            return TwitterClient.client.mentions!.count
        } else {
            return 0
        }
    }
    
    func returnFromComposeView() {
        UIView.animateWithDuration(0.5, animations: {
            self.behindTintImageView.alpha = 0
        })
    }
    
    func returnFromTweetView() {
        
    }
    
    func refresh(sender: AnyObject) {
        let title = "Updated " + dateFormater.stringFromDate(NSDate())
        let attrDict = NSDictionary(object: UIColor.blackColor(), forKey: NSForegroundColorAttributeName)
        let attrString = NSAttributedString(string: title, attributes: attrDict)
        TwitterClient.client.updateStatuses()
        feedTableView.reloadData()
        refreshControl!.attributedTitle = attrString
        refreshControl?.endRefreshing()
    }
}

