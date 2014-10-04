//
//  StatusTableViewCell.swift
//  Twitter
//
//  Created by Tianyu Shi on 9/24/14.
//  Copyright (c) 2014 Tianyu. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var dateFormatter: NSDateFormatter
    
    var status: Status! {
        willSet(status) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() in
                let imageRequest = NSURL.URLWithString(status.profileImageURL)
                var err: NSError?
                let imageData = NSData.dataWithContentsOfURL(imageRequest,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
                if err == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.userImageView.image = UIImage(data: imageData)
                        self.userImageView.layer.cornerRadius = 3
                        self.userImageView.clipsToBounds = true
                    })
                }
            })
            nameLabel.text = status.name
            usernameLabel.text = "@" + status.username
            tweetLabel.text = status.text
            tweetLabel.sizeToFit()
            
            var formattedDate: String?
            let timeDiff = NSDate().timeIntervalSince1970 - status.timeStamp!
            if timeDiff/(3600) > 24 {
                let date = NSDate.dateWithTimeIntervalSinceReferenceDate(status.timeStamp!)
                formattedDate = dateFormatter.stringFromDate(date)
            } else {
                formattedDate = NSString(format: "%.0f", timeDiff/(3600)) + " h"
            }
            
            timeStampLabel.text = formattedDate
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFromString("MMM dd")
        super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
