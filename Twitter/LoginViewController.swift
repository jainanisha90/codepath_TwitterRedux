//
//  ViewController.swift
//  Twitter
//
//  Created by Anisha Jain on 4/11/17.
//  Copyright © 2017 Anisha Jain. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(_ sender: Any) {
        TwitterClient.sharedInstance.login(success: {
                // perform segue
                self.performSegue(withIdentifier: "loginSegue", sender: self)
        }) { error in 
            print("Error: ", error.localizedDescription)
        }
    }

}

