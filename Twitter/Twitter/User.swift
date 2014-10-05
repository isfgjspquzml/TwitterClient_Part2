//
//  User.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/27/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var username: String?
    var location: String?
    var profileImage: UIImage?
    var profileBackgroundImage: UIImage?
    var tagLine: String?
    var favoritesCount: String?
    var retweetCount: String?
    var followersCount: String?
    var following: String?
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as? String
        self.username = dictionary["screen_name"] as? String
        self.location = dictionary["location"] as? String
        self.tagLine = dictionary["description"] as? String ?? ""
        self.favoritesCount = String(dictionary["status"]!["favorite_count"]! as Int) ?? ""
        self.retweetCount = String(dictionary["status"]!["retweet_count"]! as Int) ?? ""
        self.followersCount = String(dictionary["friends_count"]! as Int) ?? ""
        self.following = String(dictionary["following"] as Int) ?? ""
        
        let profileURL = dictionary["profile_image_url"] as? String ?? ""
        let imageRequest = NSURL.URLWithString(profileURL)
        var err: NSError?
        let imageData = NSData.dataWithContentsOfURL(imageRequest,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        if err == nil {
            self.profileImage = UIImage(data: imageData)
        }
        
        err = nil
        
        let backgroundURL = dictionary["profile_background_image_url"] as? String ?? ""
        let backgroundImageRequest = NSURL.URLWithString(backgroundURL)
        let backgroundImageData = NSData.dataWithContentsOfURL(backgroundImageRequest, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        if err == nil {
            self.profileBackgroundImage = UIImage(data: backgroundImageData)
        }
        println(self.profileBackgroundImage)
    }
}
