//
//  User.swift
//  Twitter
//
//  Created by Anisha Jain on 4/12/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCuurentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

enum Notifications: String {
    
    case userDidLoginNotification = "userDidLoginNotification"
    case userDidLogoutNotification = "userDidLogoutNotification"
    
    var name : Notification.Name  {
        return Notification.Name(rawValue: self.rawValue )
    }
}

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: URL?
    var backgroundImageUrl: URL?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    var tagline: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        if let profileImageUrlString = dictionary["profile_image_url"] as? String {
            profileImageUrl = URL(string: profileImageUrlString)
        }
        
        if let bannerImageUrlString = dictionary["profile_banner_url"] as? String {
            backgroundImageUrl = URL(string: bannerImageUrlString)
        } else if let backgroundImageUrlString = dictionary["profile_background_image_url"] as? String {
            backgroundImageUrl = URL(string: backgroundImageUrlString)
        }
        
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        tweetsCount = dictionary["statuses_count"] as? Int
        tagline = dictionary["description"] as? String
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = UserDefaults.standard.object(forKey: currentUserKey) as? Data
                if data != nil {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch {
                        
                    }
                }
            }
           return _currentUser
        }
        
        set(user) {
            _currentUser = user

            if _currentUser != nil {
                do {
                    let data = try JSONSerialization.data(withJSONObject: user!.dictionary, options: [])
                    UserDefaults.standard.set(data, forKey: currentUserKey)
                } catch {
                    UserDefaults.standard.removeObject(forKey: currentUserKey)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: currentUserKey)
            }
            UserDefaults.standard.synchronize()

        }
    }
 
}
