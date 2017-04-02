//
//  ChatViewController.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 23/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ChatViewController: UIViewController, UITextViewDelegate {
    
    static let Message   = "message"
    static let Cell      = "cell"
    static let Terminate = "terminate"
    static let WhoSend   = "whoSend"
    static let ChatTxtViewBottomConstraintIntialValue : CGFloat = 20.0
    
    var orderedDataSource = ( messages : [String]() , whoSend : [String]()) // ([messages] : [Whosend]) in sorted order
    var dataSource = [String : Any]() {
        didSet {
            print("Data Source : \(dataSource)")
            orderedDataSource = retrieveMessage()
            tableView.reloadData()
            
            // give some delay and scroll to the last message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                let numberOfRows = self.tableView.numberOfRows(inSection: 0)
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var chatTxtView: UITextView! {
        didSet {
            chatTxtView.layer.cornerRadius = 10
            chatTxtView.delegate = self
        }
    }
    
    @IBOutlet weak var chatTextViewBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var send: UIButton!
    private var chatRef : FIRDatabaseReference!
    
    //MARK:- Close Chat
    
    @IBAction func close(_ sender: UIButton) {
        chatRef.child(DataBaseConstants.ChatTermination).setValue([ChatViewController.Terminate : "true"])
        PlayerManager.sharedInstance.modeOfPlay = .online
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Send
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        if let chatRef = chatRef, chatTxtView.text != "", let appDel = UIApplication.shared.delegate as? AppDelegate {
            let whoSend = appDel.loggedInUser?.name ?? "Unknown"
            
            let sendDictionary = [ChatViewController.Message : chatTxtView.text , ChatViewController.WhoSend : "\(whoSend)"] as [String : Any]
            chatRef.child("\(epochNumber())").setValue(sendDictionary)
            self.chatTxtView.resignFirstResponder()
            self.chatTxtView.text = ""
        }
    }
    
    private func epochNumber() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
    
    //MARK:- Fetch data from server 
    
    func fetchData() {
        
        if let chatRef = chatRef {
            
            // check first the termination condition
            chatRef.child(DataBaseConstants.ChatTermination).observe(.value, with: { (snapShot) in
                if let values = snapShot.value as? [String : String]{
                    if let terminateChat = values[ChatViewController.Terminate], terminateChat == "true" {
                        // clear the chat history from Back - end
                        if let appDel = UIApplication.shared.delegate as? AppDelegate {
                            appDel.clearChatChannel()
                            appDel.clearLockChannel()
                            appDel.clearRequestChannel()
                            appDel.moveToOpenChannelAfterChat()
                            appDel.playingWith = nil
                            PlayerManager.sharedInstance.isRequestSentByMe = false
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            })
            
            // retrieve the data
            chatRef.observe(.value, with: { snapShot in
                if let values = snapShot.value as? [String : Any] {
                    self.dataSource = values
                }
            })
        }
    }
    
    //MARK:- ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate , let uid = appDelegate.loggedInUser?.userId , let playingWithUserID = appDelegate.playingWith?.userId
        {
            
            // check "common-chats" channel
            let commonChatChannel = appDelegate.ref.child(DataBaseConstants.CommonChat)
            if PlayerManager.sharedInstance.isRequestSentByMe {
                chatRef = commonChatChannel.child("\(uid)-\(playingWithUserID)")
            } else {
                chatRef = commonChatChannel.child("\(playingWithUserID)-\(uid)")
            }
            fetchData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: { (notifiction) in
            // when keyboard will appear this block will excute
            if let userInfo = notifiction.userInfo {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                   self.chatTextViewBottomConstraints.constant = keyboardSize.height + ChatViewController.ChatTxtViewBottomConstraintIntialValue
                }
            }
        })
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: OperationQueue.main, using: { (notifiction) in
            // when keyboard will hide this block will excute
            self.chatTextViewBottomConstraints.constant = ChatViewController.ChatTxtViewBottomConstraintIntialValue
        })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllObservers()
    }
    
    deinit {
        removeAllObservers()
    }
    private func removeAllObservers() {
        chatRef.removeAllObservers()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Retrieve message
    
    private func retrieveMessage() -> (messages :[String], whoSend:[String]) {
        var retrives = (messages :[String](), whoSend:[String]())
        let sortedKeys =  Array(dataSource.keys).sorted(by: <)
        
        for key in sortedKeys {
            if let eachData = self.dataSource[key] as? [String : String] {
                if let msg = eachData[ChatViewController.Message], let whoSend = eachData[ChatViewController.WhoSend] {
                    retrives.messages.append(msg)
                    retrives.whoSend.append(whoSend)
                }
            }
        }
        return retrives
    }
    
    //MARK:- TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
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

//MARK:- Data Source and Delegate 

extension ChatViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedDataSource.messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ChatCellTableViewCell {
            if indexPath.row < orderedDataSource.messages.count && indexPath.row < orderedDataSource.whoSend.count{
                cell.textLbl.text = orderedDataSource.whoSend[indexPath.row] + " : " + orderedDataSource.messages[indexPath.row]
            }
            return cell
        }
        return UITableViewCell()
    }
}







