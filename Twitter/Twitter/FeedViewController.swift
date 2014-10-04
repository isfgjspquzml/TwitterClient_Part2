//
//  ViewController.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/24/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    let client: TwitterClient = TwitterClient()
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var behindTintImageView: UIImageView!
    
    let dateFormater = NSDateFormatter()
    var refreshControl: UIRefreshControl?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        TwitterClient.client.feedViewController = self
        TwitterClient.client.getAccount()
        
        dateFormater.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
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
        let status = TwitterClient.client.statuses![indexPath.row]
        cell.status = status
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TwitterClient.client.statuses?.count > 0 {
            return TwitterClient.client.statuses!.count
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

