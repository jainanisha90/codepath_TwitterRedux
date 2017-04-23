//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/21/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import MBProgressHUD

let reloadUserTimeline = Notification.Name("reloadUserTimeline")

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var showProfile = false
    var user: User?
    var tweets: [Tweet]!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TweetCell")
        
        let profileHeaderViewNib = UINib(nibName: "ProfileHeaderView", bundle: nil)
        tableView.register(profileHeaderViewNib, forCellReuseIdentifier: "ProfileHeaderView")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        refreshControl.addTarget(self, action: #selector(loadUserTimelineData), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Adding listener to reload HomeTimeline
        NotificationCenter.default.addObserver(forName: reloadUserTimeline, object: nil, queue: OperationQueue.main) { (notification) in
            self.refreshControl.beginRefreshing()
            self.loadUserTimelineData()
        }
        getUserProfile()
        loadUserTimelineData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserProfile() {
        let userScreenName: String?
        if user != nil {
            userScreenName = user?.screenName
        } else {
            userScreenName = User.currentUser?.screenName
        }
        TwitterClient.sharedInstance.getUserProfile(screenName: userScreenName!) { (user, error) in
            //print("name", user?.name)
            self.showProfile = true
            self.user = user
            self.tableView.reloadData()
        }
    }
    
    func loadUserTimelineData() {
        let userScreenName: String?
        if user != nil {
            userScreenName = user?.screenName
        } else {
            userScreenName = User.currentUser?.screenName
        }
        TwitterClient.sharedInstance.userTimelineWithParams(screenName: userScreenName!) { (tweets, error) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tweetCount = tweets?.count ?? 0
        return showProfile ? (tweetCount + 1) : tweetCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (showProfile && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView
            cell.user = self.user
            return cell
        } else {
            let rowIndex = showProfile ? (indexPath.row - 1) : indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
            
            cell.tweet = tweets[rowIndex]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && showProfile {
            return
        }
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: "tweetDetailsSegue", sender: cell)
    }
    
    
    func tweetCell(tweetCell: TweetCell, onReply reply: String?) {
        self.performSegue(withIdentifier: "replySegue", sender: tweetCell)
    }
    
    func tweetCell(tweetCell: TweetCell, onRetweet retweet: String?) {
        let tweetId = getTweet(tweetCell).tweetId!
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance.retweet(tweetId: tweetId, success: {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.refreshControl.beginRefreshing()
            self.loadUserTimelineData()
            NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
        }, failure: { (error) in
            print("Error during posting a tweet", error)
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func tweetCell(tweetCell: TweetCell, onFavorite favorite: Bool) {
        let tweet = getTweet(tweetCell)
        let tweetId = tweet.tweetId!
        print("tweetID: \(tweetId)")
        if favorite {
            TwitterClient.sharedInstance.createFavorite(tweetId: tweetId, success: {
                // Updating local favorite count
                tweet.favorited = favorite
                tweet.favoriteCount! += 1
            }, failure: { (error) in
                print("Error during posting a tweet", error)
            })
        } else {
            TwitterClient.sharedInstance.removeFavorite(tweetId: tweetId, success: {
                tweet.favorited = favorite
                tweet.favoriteCount! -= 1
            }, failure: { (error) in
                print("Error during posting a tweet", error)
            })
        }
    }
    
    private func getTweet(_ tweetCell: TweetCell) -> Tweet {
        let indexPath = tableView.indexPath(for: tweetCell as UITableViewCell)
        let rowIndex = showProfile ? (indexPath!.row - 1) : indexPath!.row
        let tweet = tweets[rowIndex]
        return tweet
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "replySegue" {
            let tweet = getTweet(sender as! TweetCell)
            let navigationController = segue.destination as! UINavigationController
            let rvc = navigationController.topViewController as! ReplyViewController
            rvc.tweet = tweet
            
        } else if segue.identifier == "tweetDetailsSegue" {
            let tweet = getTweet(sender as! TweetCell)
            let tweetDetailsController = segue.destination as! TweetDetailsViewController
            tweetDetailsController.tweet = tweet
        }
    }
}
