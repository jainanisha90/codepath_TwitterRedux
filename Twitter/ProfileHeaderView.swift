//
//  ProfileHeaderView.swift
//  Twitter
//
//  Created by Anisha Jain on 4/22/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit

class ProfileHeaderView: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var user : User! {
        didSet {
            userNameLabel.text  = user?.name
            profileImageView.setImageWith((user?.profileImageUrl)!)
            screenNameLabel.text = "@\(user!.screenName!)"
            backgroundImageView.setImageWith((user?.backgroundImageUrl)!)
            followingCountLabel.text = "\(user!.followingCount!)"
            followersCountLabel.text = "\(user!.followersCount!)"
            tweetsCountLabel.text = "\(user!.tweetsCount!)"
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
    }
    

}
