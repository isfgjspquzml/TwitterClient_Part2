//
//  Status.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/24/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class Status: NSObject {
    
    var name: NSString
    var username: NSString
    var profileImageURL: NSString
    var text: NSString
    var urlsArray: NSArray
    var hashtagArray: NSArray
    var timeStamp: NSTimeInterval?
    var retweetCount: Int
    var retweeted: Int
    var retweetId: Int?
    var favoriteCount: Int
    var favorited: Int
    var tweetId: Int

    init(dictionary: NSDictionary) {
        var userDict = dictionary["user"]! as NSDictionary
        var entitiesDict = dictionary["entities"]! as NSDictionary
        var retweetDict = dictionary["retweeted_status"] as? NSDictionary
        
        self.name = userDict["name"]! as NSString
        self.username = userDict["screen_name"]! as NSString
        self.profileImageURL = userDict["profile_image_url"]? as? NSString ?? ""
        self.text = dictionary["text"]? as? NSString ?? ""
        self.urlsArray = entitiesDict["urls"]! as NSArray
        self.hashtagArray = entitiesDict["hashtags"]! as NSArray
        self.retweetCount = dictionary["retweet_count"]! as Int
        self.retweeted = dictionary["retweeted"]! as Int
        if retweetDict != nil {
            self.retweetId = retweetDict!["id"] as? Int
        }
        self.favoriteCount = dictionary["favorite_count"]! as Int
        self.favorited = dictionary["favorited"]! as Int
        self.tweetId = dictionary["id"]! as Int
        super.init()
        self.timeStamp = convertTwitterTimeStampToDate(dictionary["created_at"]? as? NSString ?? "")
    }
    
    func convertTwitterTimeStampToDate(timeStampString: NSString) -> NSTimeInterval? {
        if timeStampString.length > 0 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            var date = dateFormatter.dateFromString(timeStampString)
            return NSTimeInterval(date!.timeIntervalSince1970)
        } else {
            return nil
        }
    }
}
