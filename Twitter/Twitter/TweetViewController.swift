//
//  TweetViewController.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/27/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var numRetweets: UILabel!
    @IBOutlet weak var numFavorites: UILabel!
    @IBOutlet weak var behindTintView: UIImageView!
    
    @IBAction func onRetweetTapped(sender: AnyObject) {
//        if status!.retweeted == 0 {
            TwitterClient.client.retweetTweet(status!.tweetId, retweeted: status!.retweeted, row: row)
//        } else {
//            TwitterClient.client.retweetTweet(status!.retweetId!, retweeted: status!.retweeted, row: row)
//        }
        let change = 1-status!.retweeted
        status!.retweetCount += change
        status!.retweeted = abs(change)
        numRetweetsChanged()
    }
    
    @IBAction func onFavoriteTapped(sender: AnyObject) {
        TwitterClient.client.favoriteTweet(status!.tweetId, favorite: status!.favorited)
        let change = 1-status!.favorited
        status!.favoriteCount += change
        status!.favorited = abs(change)
        numFavoritesChanged()
    }
    
    @IBAction func onReturnTapped(sender: AnyObject) {
        feedViewControllerDelegate!.returnFromTweetView()
        TwitterClient.client.storedReplyTweet = ""
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    var status: Status?
    var row: Int?
    var feedViewControllerDelegate: FeedViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() in
            let imageRequest = NSURL.URLWithString(self.status!.profileImageURL)
            var err: NSError?
            let imageData = NSData.dataWithContentsOfURL(imageRequest,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
            if err == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.profileImageView.image = UIImage(data: imageData)
                    self.profileImageView.layer.cornerRadius = 3
                    self.profileImageView.clipsToBounds = true
                })
            }
        })
        
        nameLabel.text = status!.name
        usernameLabel.text = "@" + status!.username
        tweetLabel.text = status!.text
        
        let dateFormater = NSDateFormatter()
        dateFormater.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        timeStampLabel.text = dateFormater.stringFromDate(NSDate(timeIntervalSince1970: status!.timeStamp!))
        
        numRetweets.text = String(status!.retweetCount)
        numRetweetsChanged()
        numFavorites.text = String(status!.favoriteCount)
        numFavoritesChanged()
        
        TwitterClient.client.currentTweetId = status!.tweetId
    }
    
    func numRetweetsChanged() {
        numRetweets.text = String(status!.retweetCount)
        if status!.retweeted == 0 {
            numRetweets.font = UIFont.systemFontOfSize(12)
        } else {
            numRetweets.font = UIFont.boldSystemFontOfSize(13)
        }
    }
    
    func numFavoritesChanged() {
        numFavorites.text = String(status!.favoriteCount)
        if status!.favorited == 0 {
            numFavorites.font = UIFont.systemFontOfSize(12)
        } else {
            numFavorites.font = UIFont.boldSystemFontOfSize(13)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tweetToComposeView" {
            let composeViewController = segue.destinationViewController as ComposeViewController
            composeViewController.tweetViewControllerDelegate = self
            UIView.animateWithDuration(0.5, animations: {
                self.behindTintView.alpha = 1
            })
        }
    }
    
    func returnFromComposeView() {
        UIView.animateWithDuration(0.5, animations: {
            self.behindTintView.alpha = 0
        })
    }
}
