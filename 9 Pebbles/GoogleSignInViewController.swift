//
//  GoogleSignInViewController.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 24/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class GoogleSignInViewController: UIViewController , GIDSignInUIDelegate {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate =  self
        // Uncomment to automatically sign in the user.
        // GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton! {
        didSet {
            googleSignInButton.layer.cornerRadius = 5
            googleSignInButton.layer.shadowOpacity = 0.5
            googleSignInButton.layer.shadowColor = UIColor.blue.cgColor
            googleSignInButton.layer.shadowRadius = 5
        }
    }
    
    //MARK:- Sign In Button Tapped
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    //MARK:- Close 
    
    @IBAction func close(_ sender: UIButton) {
        spinner.stopAnimating()
        if let appDel = UIApplication.shared.delegate as? AppDelegate , let userName = appDel.loggedInUser?.name {
            showAlertWithTimerInSignInPage(title: "Welcome!!", message: userName, completionBlock: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertWithTimerInSignInPage(title : String, message : String, completionBlock : (()-> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: {
            // give a delay and then dismiss alert
            let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                alert.dismiss(animated: true, completion: {
                    completionBlock?()
                })
            })
        })
    }
    
    //MARK:- Orientation 
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .portrait
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        } else {
            return true
        }
    }
}
