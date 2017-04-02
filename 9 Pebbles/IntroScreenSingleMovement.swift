//
//  IntroScreenSingleMovement.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 29/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit

class IntroScreenSingleMovement: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //update user default
        let userDefault = UserDefaults.standard
        userDefault.set(false, forKey: UserDefaultsConstants.SingleMoveIntroScreenKey)
        
    }

    @IBAction func gotItBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
