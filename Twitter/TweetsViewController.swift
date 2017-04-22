//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/13/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import MBProgressHUD

let reloadHomeTimeline = Notification.Name("reloadHomeTimeline")
let addMyTweetToHomeTimeline = Notification.Name("addMyTweetToHomeTimeline")

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        refreshControl.addTarget(self, action: #selector(loadHomeTimelineData), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        loadHomeTimelineData()
        
        // Adding listener to reload HomeTimeline
        NotificationCenter.default.addObserver(forName: reloadHomeTimeline, object: nil, queue: OperationQueue.main) { (notification) in
            self.refreshControl.beginRefreshing()
            self.loadHomeTimelineData()
        }
        
        // Adding listener to reload HomeTimeline
        NotificationCenter.default.addObserver(forName: addMyTweetToHomeTimeline, object: nil, queue: OperationQueue.main) { (notification) in
            print("got notification addMyTweetToHomeTimeline")
            self.tweets.insert(notification.object as! Tweet, at: 0)
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHomeTimelineData() {
        TwitterClient.sharedInstance.homeTimelineWithParams(params: nil) { (tweets, error) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            },
            failure: { (error) in
                print("Error during posting a tweet", error)
            })
        } else {
            TwitterClient.sharedInstance.removeFavorite(tweetId: tweetId, success: {
                tweet.favorited = favorite
                tweet.favoriteCount! -= 1
            },
            failure: { (error) in
                print("Error during posting a tweet", error)
            })
        }
    }
    
    private func getTweet(_ tweetCell: TweetCell) -> Tweet {
        let indexPath = tableView.indexPath(for: tweetCell as UITableViewCell)
        let tweet = tweets[(indexPath?.row)!]
        return tweet
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
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
