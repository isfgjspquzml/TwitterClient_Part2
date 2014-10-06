//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/25/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterClient: NSObject {
    class var client :TwitterClient {
    struct Singleton {
        static let instance = TwitterClient()
        }
        return Singleton.instance
    }
    
    let accountStore: ACAccountStore!
    let accountType: ACAccountType!
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var feedViewController: FeedViewController?
    var tweetViewController: TweetViewController?
    var profileViewController: ProfileViewController?
    
    var user: User?
    var queriedUser: User?
    var statuses: [Status]?
    var mentions: [Status]?
    var account: ACAccount?
    var storedTweet: String = ""
    var storedReplyTweet: String = ""
    var currentTweetId : Int?
    
    override init() {
        accountStore = ACAccountStore()
        accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    }
    
    func getAccount() {
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (success, error) in
            if success {
                let accounts = self.accountStore.accountsWithAccountType(self.accountType)
                if accounts.count > 0 {
                    self.account = accounts![0] as? ACAccount
                }
                self.updateUser()
                self.updateStatuses()
                self.updateMentions()
            } else {
                NSLog("Error: \(error)")
            }
        }
    }
    
    func updateUser() {
        if account == nil {return}
        let url = NSURL(string: "https://api.twitter.com/1.1/users/show.json")
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: NSDictionary(object: account!.username, forKey: "screen_name"))
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error getting user credentials")
                println(response)
            } else {
                let userInfo = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                self.user = User(dictionary: userInfo)
                
                if self.profileViewController != nil {
                    self.profileViewController!.reload()
                }
            }
        })
        task.resume()
    }
    
    func updateStatuses() {
        if account == nil {return}
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: nil)
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error getting timeline")
                println(response)
            } else {
                let array = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSArray
                var statusArray:[Status] = Array()
                for object in array {
                    let dictionary = object as NSDictionary
                    statusArray.append((Status(dictionary: dictionary)))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.statuses = statusArray
                    if let feedCtrl = self.feedViewController {
                        feedCtrl.feedTableView.reloadData()
                    }
                })
            }
        })
        task.resume()
    }
    
    func updateMentions() {
        if account == nil {return}
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/mentions_timeline.json")
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: nil)
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error getting mentions")
            } else {
                let array = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSArray
                var mentionsArray:[Status] = Array()
                for object in array {
                    let dictionary = object as NSDictionary
                    mentionsArray.append((Status(dictionary: dictionary)))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.mentions = mentionsArray
                })
            }
        })
        task.resume()
    }
    
    func tweetMessage(message: String, tweetID: Int?) {
        if account == nil {return}
        var params = NSMutableDictionary(object: message, forKey: "status")
        
        if tweetID != nil {
            params.setValue(tweetID!, forKey: "in_reply_to_status_id")
        }
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: params)
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error posting tweet")
            }
        })
        task.resume()
    }
    
    func retweetTweet(tweetId: Int, retweeted: Int, row: Int?) {
        if account == nil {return}
        
        var stringURL = "https://api.twitter.com/1.1/statuses/retweet/\(tweetId).json"
        if retweeted == 1 {
            stringURL = "https://api.twitter.com/1.1/statuses/destroy/\(tweetId).json"
        }
        
        let url = NSURL(string: stringURL)
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: nil)
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error posting retweet")
            } else {
                let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
//                if retweeted == 0 {
//                    let retweetId = dict["retweeted_status"]!["id"]! as Int
//                    TwitterClient.client.statuses![row!].retweetId = retweetId
//                }
            }
        })
        task.resume()
    }
    
    func favoriteTweet(tweetId: Int, favorite: Int) {
        if account == nil {return}
        
        var stringAction = "create"
        if favorite == 1 {
            stringAction = "destroy"
        }
        
        let urlString = "https://api.twitter.com/1.1/favorites/" + stringAction + ".json?id=" + String(tweetId)
        let url = NSURL(string: urlString)
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: nil)
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                NSLog("Error favoriting tweet")
            } else {
                let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            }
        })
        task.resume()
    }
    
    func getUserTimeline(userId: String) {
        if account == nil {return}
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let authRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: NSDictionary(object: userId, forKey: "user_id"))
        
        authRequest.account = account
        let request = authRequest.preparedURLRequest()
        
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if error != nil {
                NSLog("Error getting user timeline")
            } else {
                let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                self.queriedUser = User(dictionary: dict)
            }
        })
        task.resume()
    }
}
