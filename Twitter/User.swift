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
    var tagline: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        let profileImageUrlString = dictionary["profile_image_url"] as? String
        if profileImageUrlString != nil {
            profileImageUrl = URL(string: profileImageUrlString!)
        } else {
            profileImageUrl = nil
        }
        
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
