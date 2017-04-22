//
//  ReplyViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/15/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit
import MBProgressHUD

class ReplyViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var replyTextView: UITextView!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replyTextView.delegate = self
        replyTextView.text = "Tweet your reply"
        replyTextView.textColor = .lightGray
        replyTextView.becomeFirstResponder()
        
        let tweetAuthor = (tweet?.user?.screenName)!
        replyToLabel.text = "Reply to @\(tweetAuthor)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            textView.text = "Tweet your reply"
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
    
    @IBAction func onReplyButton(_ sender: Any) {
        if let text = replyTextView.text {
            let tweetAuthor = (tweet?.user?.screenName)!
            let tweetId = tweet?.tweetId!
            let tweetMessage = "@\(tweetAuthor) \(text)"
            //print("tweetMessage: \(tweetMessage), tweetId: \(tweetId!)")
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            TwitterClient.sharedInstance.reply(tweetMessage: tweetMessage, tweetId: tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
