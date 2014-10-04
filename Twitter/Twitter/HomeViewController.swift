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
        let mentionsViewController = sb.instantiateViewControllerWithIdentifier("mentionsViewController") as UIViewController
        viewControllers = [profileViewController, feedViewController, mentionsViewController]
    }
    
    override func viewDidLoad() {
        self.contentViewCenterX.constant = 0
        self.activeViewController = viewControllers![2]
    }
    
    @IBAction func didTapProfile(sender: UIButton) {
        self.contentViewCenterX.constant = 0
        self.activeViewController = viewControllers![0]
    }
    
    @IBAction func didTapTimeline(sender: UIButton) {
        self.contentViewCenterX.constant = 0
        self.activeViewController = viewControllers![1]
    }
    
    @IBAction func didTapMentions(sender: UIButton) {
        self.contentViewCenterX.constant = 0
        self.activeViewController = viewControllers![2]
    }
    
    @IBAction func contentViewSwiped(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended {
            UIView.animateWithDuration(0.4, animations: {
                self.contentViewCenterX.constant = -160
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
            }
        }
    }
}