//
//  Page1ViewController.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 15/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit

class Page1ViewController: UIViewController {
    
    @IBOutlet weak var textView1: UITextView! {
        didSet {
            textView1.isUserInteractionEnabled = false
            textView1.text = IntroductionConstants.text1
        }
    }
    @IBAction func start(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
class Page2ViewController : UIViewController {
    @IBAction func start(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var textView2: UITextView! {
        didSet {
            textView2.isUserInteractionEnabled = false
            textView2.text = IntroductionConstants.text2
        }
    }
}
class Page3ViewController : UIViewController {
    @IBAction func start(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var textView3: UITextView! {
        didSet {
            textView3.isUserInteractionEnabled = false
            textView3.text = IntroductionConstants.text3
        }
    }
}
class Page4ViewController : UIViewController {
    @IBOutlet weak var textView4: UITextView! {
        didSet {
            textView4.isUserInteractionEnabled = false
            textView4.text = IntroductionConstants.text4
        }
    }
    @IBAction func start(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

class Page5ViewController : UIViewController {
    @IBAction func start(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var textView5: UITextView! {
        didSet {
            textView5.isUserInteractionEnabled = false
            textView5.text = IntroductionConstants.text5
        }
    }
}
