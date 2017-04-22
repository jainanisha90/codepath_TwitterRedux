//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/15/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import MBProgressHUD

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    @IBOutlet weak var currentUserScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        tweetTextView.text = "Type your tweet"
        tweetTextView.textColor = .lightGray
        tweetTextView.becomeFirstResponder()
        
        let currentUser = User.currentUser
        currentUserImageView.setImageWith((currentUser?.profileImageUrl)!)
        currentUserNameLabel.text = currentUser?.name
        currentUserScreenNameLabel.text = currentUser?.screenName
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTweetButton(_ sender: Any) {
        
        if let tweetMessage = tweetTextView.text {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            TwitterClient.sharedInstance.newTweet(tweetMessage: tweetMessage, success: {
                MBProgressHUD.hide(for: self.view, animated: true)

                // Passing new tweet to tweetsViewController to display on home timeline
                let newTweet = Tweet(currentUser: User.currentUser, tweetMessage: tweetMessage, createdAt: Date())
                NotificationCenter.default.post(name: addMyTweetToHomeTimeline, object: newTweet)
                
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print("Error during posting a tweet", error)
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        }
    }
   
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // Set cursor to the beginning if placeholder is set
        if textView.textColor == .lightGray {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Remove placeholder
        if textView.textColor == .lightGray && text.characters.count > 0 {
            textView.text = ""
            textView.textColor = .black
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Set placeholder if text is empty
        if textView.text.isEmpty {
            textView.text = "Type your tweet"
            textView.textColor = .lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // Set cursor to the beginning if placeholder is set
        let firstPosition = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        // Do not change position recursively
        if textView.textColor == .lightGray && textView.selectedTextRange != firstPosition {
            textView.selectedTextRange = firstPosition
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
