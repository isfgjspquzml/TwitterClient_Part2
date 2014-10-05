//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Tianyu Shi on 10/4/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TwitterClient.client.profileViewController = self
        
        if let user = TwitterClient.client.user {
            reload()
        }
    }
    
    func reload() {
        let user = TwitterClient.client.user!
        backgroundImageView.image = TwitterClient.client.user!.profileBackgroundImage
        profileImageView.image = user.profileImage
        nameLabel.text = user.name
        usernameLabel.text = "@" + user.username!
        locationLabel.text = user.location
        taglineLabel.text = user.tagLine
        favoriteCount.text = "Favorites: " + user.favoritesCount!
        retweetCount.text = "Retweets: " + user.retweetCount!
        followersCount.text = "Followers: " + user.followersCount!
        followingCount.text = "Following: " + user.following!
    }

    override func loadView() {
        super.loadView()
    }
}
