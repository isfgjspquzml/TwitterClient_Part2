//
//  HomeViewController.swift
//  Twitter
//
//  Created by Tianyu Shi on 10/3/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sidebarView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewCenterX: NSLayoutConstraint!
    
//    var viewControllers: [UIViewController] = [ProfileViewController(nibName: nil, bundle: nil), FeedViewController(nibName: nil, bundle: nil), MentionsViewController(nibName: nil, bundle: nil)]
    var viewControllers: [UIViewController]?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = sb.instantiateViewControllerWithIdentifier("profileViewController") as UIViewController
        let feedViewController = sb.instantiateViewControllerWithIdentifier("feedViewController") as UIViewController
        viewControllers = [profileViewController, feedViewController]
    }
    
    override func viewDidLoad() {
        self.contentViewCenterX.constant = 0
        self.activeViewController = viewControllers![1]
        self.title = "Timeline"
    }
    
    @IBAction func didTapProfile(sender: UIButton) {
        closeMenu()
        (self.viewControllers![0] as ProfileViewController).showSelf = true
        (self.viewControllers![0] as ProfileViewController).reload()
        self.title = TwitterClient.client.user?.username
        self.activeViewController = viewControllers![0]
    }
    
    @IBAction func didTapTimeline(sender: UIButton) {
        closeMenu()
        (self.viewControllers![1] as FeedViewController).showFeed = true
        (self.viewControllers![1] as FeedViewController).feedTableView.reloadData()
        self.title = "Timeline"
        self.activeViewController = viewControllers![1]
    }
    
    @IBAction func didTapMentions(sender: UIButton) {
        closeMenu()
        (self.viewControllers![1] as FeedViewController).showFeed = false
        (self.viewControllers![1] as FeedViewController).feedTableView.reloadData()
        self.title =  "Mentions"
        self.activeViewController = viewControllers![1]
    }
    
    func closeMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.contentViewCenterX.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func contentViewSwiped(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended {
            UIView.animateWithDuration(0.4, animations: {
                self.contentViewCenterX.constant = -160
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func contentViewSwipedLeft(sender: AnyObject) {
        if sender.state == .Ended {
            UIView.animateWithDuration(0.4, animations: {
                self.contentViewCenterX.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
                if newVC == self.viewControllers![0] {
                    (newVC as ProfileViewController).reload()
                }
            }
            self.view.layoutIfNeeded()
        }
    }
}
