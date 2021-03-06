//
//  TweetCell.swift
//  Twitter
//
//  Created by Anisha Jain on 4/15/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
@objc protocol TweetCellDelegate {
    @objc optional func tweetCell(tweetCell:TweetCell, onReply reply: String?)
    @objc optional func tweetCell(tweetCell:TweetCell, onRetweet retweet: String?)
    @objc optional func tweetCell(tweetCell:TweetCell, onFavorite favorite: Bool)
    @objc optional func tweetCell(onTapProfileImage tweetCell:TweetCell)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet : Tweet! {
        didSet {
            userNameLabel.text  = tweet.user?.name
            profileImageView.setImageWith((tweet.user?.profileImageUrl)!)
            screenNameLabel.text = "@\(tweet!.user!.screenName!)"
            postTextLabel.text = tweet.text
            createdAtLabel.text = "\(tweet.createdAt!)"
            favoriteButton.isSelected = tweet.favorited
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState.normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "favoriteSelected"), for: UIControlState.selected)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnImage(sender:)))
        tapGesture.numberOfTapsRequired = 1
        
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    func handleTapOnImage(sender: UITapGestureRecognizer) {
        delegate?.tweetCell?(onTapProfileImage: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    @IBAction func onReplyButton(_ sender: Any) {
        delegate?.tweetCell?(tweetCell: self, onReply: nil)
    }

    @IBAction func onRetweetButton(_ sender: Any) {
        delegate?.tweetCell?(tweetCell: self, onRetweet: nil)
    }

    @IBAction func onFavoriteButton(_ sender: Any) {
        let isFavorite = sender as! UIButton
        isFavorite.isSelected = !(isFavorite.isSelected)
        delegate?.tweetCell?(tweetCell: self, onFavorite: isFavorite.isSelected)
    }

}
