//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/16/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState.normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "favoriteSelected"), for: UIControlState.selected)
        
        profileImageView.setImageWith((tweet?.user?.profileImageUrl)!)
        userNameLabel.text = tweet?.user?.name
        screenNameLabel.text = tweet?.user?.screenName
        tweetTextLabel.text = tweet?.text
        retweetCountLabel.text = String(describing: tweet!.retweetCount!)
        favoriteCountLabel.text = String(describing: tweet!.favoriteCount!)
        timestampLabel.text = tweet?.timeStamp
        
        favoriteButton.isSelected = tweet!.favorited
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onReplyButton(_ sender: Any) {
        print("Reply button tapped")
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        let tweetId = tweet!.tweetId!
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance.retweet(tweetId: tweetId, success: {
            // Updating local retweet count when retweet API return success
            self.retweetCountLabel.text =  String(describing: (self.tweet!.retweetCount! + 1))
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
        }, failure: { (error) in
            print("Error during posting a tweet", error)
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        let tweetId = tweet!.tweetId!
        print("tweetID: \(tweetId)")
        let isFavorite = sender as! UIButton
        isFavorite.isSelected = !(isFavorite.isSelected)
        if isFavorite.isSelected {
            TwitterClient.sharedInstance.createFavorite(tweetId: tweetId, success: {
                // Updating local favorite count when favorite API return success
                self.tweet?.favoriteCount = self.tweet!.favoriteCount! + 1
                self.favoriteCountLabel.text =  String(describing: self.tweet!.favoriteCount!)
                NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
            }, failure: { (error) in
                print("Error during posting a tweet", error)
            })
        } else {
            TwitterClient.sharedInstance.removeFavorite(tweetId: tweetId, success: {
                self.tweet?.favoriteCount = self.tweet!.favoriteCount! - 1
                self.favoriteCountLabel.text =  String(describing: self.tweet!.favoriteCount!)
                NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
            }, failure: { (error) in
                print("Error during posting a tweet", error)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "replyFromDetailSegue" {
            let navigationController = segue.destination as! UINavigationController
            let rvc = navigationController.topViewController as! ReplyViewController
            rvc.tweet = tweet
        }
    }
}
