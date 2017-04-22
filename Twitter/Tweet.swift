//
//  Tweet.swift
//  Twitter
//
//  Created by Anisha Jain on 4/12/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var userName: String?
    var text: String?
    var createdAt: String?
    var timeStamp: String?
    var tweetId: String?
    var retweetCount: Int?
    var favoriteCount: Int?
    var favorited = false

    init(dictionary: NSDictionary) {
        super.init()
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAt = timeSinceTweet((dictionary["created_at"] as? String!)!)
        retweetCount = dictionary["retweet_count"] as? Int
        tweetId = dictionary["id_str"] as? String
        favoriteCount = dictionary["favorite_count"] as? Int
        favorited = dictionary["favorited"] as? Bool ?? false
    }
    
    init(currentUser: User?, tweetMessage: String, createdAt: Date) {
        super.init()
        user = currentUser
        text = tweetMessage
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = timeSinceTweet(formatter.string(from: createdAt))
    }
    
    func timeSinceTweet(_ createdAtString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let startDate = formatter.date(from: createdAtString)
        
        formatter.dateFormat = "M/d/yy, H:mm a"
        timeStamp = formatter.string(from: startDate!)
        
        let now = Date()
        let components = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: startDate!, to: now)
        
        let weeks = components.month!
        let days = components.day!
        let hours = components.hour!
        let min = components.minute!
        let sec = components.second!
        
        var timeSinceTweet = ""
        
        if (sec > 0) {
            timeSinceTweet = "\(sec)s"
        }
        if (min > 0) {
            timeSinceTweet = "\(min)m"
        }
        if (hours > 0) {
            timeSinceTweet = "\(hours)h"
        }
        if (days > 0) {
            timeSinceTweet = "\(days)d"
        }
        if (weeks > 0) {
            timeSinceTweet = "\(weeks)w"
        }
        return timeSinceTweet
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
