//
//  TwitterClient.swift
//  Twitter
//
//  Created by Anisha Jain on 4/14/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "2wBWxpkRFY6io5dZTY0uT7y61"
let twitterConsumerSecret = "6NdyWeWsDOMCpwHsntMTraTIWX6iSjYFF6J1yuTo4UNHxhQOvk"
let twitterBaseURL = URL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        // Fetch request token and redirect to authorization page
        requestSerializer.removeAccessToken()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL:
            URL(string: "twitterdemotrial://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("Got request token")
                let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")
                UIApplication.shared.open(authURL!)
        }) { (error: Error!) -> Void in
            print("failed to get request token")
            self.loginFailure?(error)
        }
        print("escaping")
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: Notifications.userDidLogoutNotification.name, object: nil)
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        self.get("1.1/account/verify_credentials.json", parameters: nil, success:
            { (operation: URLSessionDataTask!, response: Any!) -> Void in
                let user = User(dictionary: response as! NSDictionary)
                success(user)
                User.currentUser = user
                print("user: ", user.name!)
                self.loginSuccess?()
        }, failure: { (operation: URLSessionDataTask!, error: Error!) -> Void in
            failure(error)
            print("Error getting current user")
        })
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: URLSessionDataTask!, response: Any!) -> Void in
                let tweets = Tweet.tweetsWithArray(array: response as! [NSDictionary])
                completion(tweets, nil)
                //print("hometimeline: ", response)
        }, failure: { (operation: URLSessionDataTask!, error: Error!) -> Void in
            print("Error getting home timeline", error)
            completion(nil, error)
        })
    }
    
    private func sendUpdate(params: Any?, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/update.json", parameters: params,
             success: { (operation: URLSessionDataTask, response: Any) in
                success()
                //print("newTweet response: ", response)
        }) { (urlSessionDataTask, error) in
            print("Falied to post a tweet")
            failure(error)
        }
    }
    
    
    func newTweet(tweetMessage: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let params = ["status": tweetMessage]
        sendUpdate(params: params, success: success, failure: failure)
    }
    
    func reply(tweetMessage: String, tweetId: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let params = ["status": tweetMessage, "in_reply_to_status_id": tweetId]
        sendUpdate(params: params, success: success, failure: failure)
    }
    
    func retweet(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        print("tweet API: 1.1/statuses/retweet/\(tweetId).json")
        post("1.1/statuses/retweet/\(tweetId).json", parameters: nil,
             success: { (operation: URLSessionDataTask, response: Any) in
                success()
                //print("retweet response: ", response)
        }) { (urlSessionDataTask, error) in
            print("Falied to retweet")
            failure(error)
        }
    }
    
    func createFavorite(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let params = ["id": tweetId]
        post("1.1/favorites/create.json", parameters: params,
             success: { (operation: URLSessionDataTask, response: Any) in
                success()
                //print("createFavorite response: ", response)
        }) { (urlSessionDataTask, error) in
            print("Falied to create favorite tweet")
            failure(error)
        }
    }
    
    func removeFavorite(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let params = ["id": tweetId]
        post("1.1/favorites/destroy.json", parameters: params,
             success: { (operation: URLSessionDataTask, response: Any) in
                success()
                //print("removeFavorite response: ", response)
        }) { (urlSessionDataTask, error) in
            print("Falied to remove favorite tweet")
            failure(error)
        }
    }
    
    func handleOpenURL(url: URL) {
        fetchAccessToken(withPath: "oauth/access_token",
                         method: "POST",
                         requestToken: BDBOAuth1Credential(queryString: url.query),
                         success: { (access_token: BDBOAuth1Credential!) -> Void in
                            print("got access token")
                            self.requestSerializer.saveAccessToken(access_token)
                            self.currentAccount(success: { (user: User) in
                                User.currentUser = user
                                self.loginSuccess?()
                            }, failure: { (error: Error) in
                                self.loginFailure?(error)
                            })
        }) { (error: Error!) -> Void in
            print("failed to get access token")
            self.loginFailure?(error)
        }
    }
    
}
