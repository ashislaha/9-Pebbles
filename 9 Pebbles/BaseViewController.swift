//
//  ViewController.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 21/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn


protocol BaseViewProtocol {
    func showAlert(_ message : String, type : AlertType)
    func showSingleMoveIntro()
    func showSingleMovementOptions(_ sender : PebbleButton)
    func updatePebblesCount()
    func showAlertWithTimer(title : String, message : String , completionBlock : (()-> Void)? )
    func animate(fromButton : Int , toButton : Int, completionBlock : (()-> Void)?)
}


class BaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK:- Outlets for views 
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var optionsView: OptionsView!
    @IBOutlet weak var tableViewInsideGameView: UITableView!
    
    //MARK:- Outlets for optional views
    
    @IBOutlet weak var player1OwnPebbles: UILabel! 
    @IBOutlet weak var player1ClaimingPebbles: UILabel!
    @IBOutlet weak var player2OwnPebbles: UILabel!
    @IBOutlet weak var player2ClaimimgPebbles: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var player1Score: UILabel!
    
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    
    //MARK:- Instance Variable
    
    var currentButtonForOptions : PebbleButton?
    var playerLabel: UILabel!
    var modeOfPlayLabel : UILabel!
    var movementButton : UIButton!
    var isChatButtonBlinking = false
    var basicOpacityAnimation : CABasicAnimation!
    
    //MARK:- Table View Data Source 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        var identifier : String!
        
        switch (indexPath as NSIndexPath).row + 1 {
            case 1: identifier = TableViewCellConstants.Cell1
            case 2: identifier = TableViewCellConstants.Cell2
            case 3: identifier = TableViewCellConstants.Cell3
            case 4: identifier = TableViewCellConstants.Cell4
            case 5: identifier = TableViewCellConstants.Cell5
            case 6: identifier = TableViewCellConstants.Cell6
            case 7: identifier = TableViewCellConstants.Cell7
            default: break
        }
        cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }
    
    
    //MARK:- View Controller Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check for iPad and iPhone 4
        if !deviceCheck() {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                let alert = UIAlertController(title: "Sorry", message: "I am working on that device layout. Please.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    print("ok pressed")
                    exit(0)
                }))
                self.present(alert, animated: true, completion: nil)
            })
            
        } else {
            
            signOut.isHidden = true
            signInTapped(UIButton())
            
            PlayerManager.sharedInstance.player = CurrentPlayer.player1 //default is the player1
            PlayerManager.sharedInstance.modeOfPlay = .withiOS
            let _ = ColorManager.init() // to reset the color array
            
            let userDefault = UserDefaults.standard
            userDefault.set(true, forKey: UserDefaultsConstants.SingleMoveIntroScreenKey)
            
            if let scoreValue = userDefault.value(forKey: UserDefaultsConstants.player1Score) as? Int {
                player1Score.text = "\(scoreValue)"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if deviceCheck() {
            StoredPoints.calculatePoints()
            needsSetDisplayForAllTableCell()
            self.fetchRequest()
            self.fetchLockUser()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
    
    
    //MARK:- Fetch Request
    
    private func fetchRequest() {
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate , let uid = appDel.loggedInUser?.userId  {
            
            let requestChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.RequestUsers)
            //retrieve request users
            requestChannel.observe(.value, with: { (snapShot) in
                if let dictionary = snapShot.value as? [String : [String : String]]  {
                    for (key,value) in dictionary {
                        // key is (UID of from User-UID of to User) 
                        let seperatorArr = key.components(separatedBy: "-")
                        if seperatorArr.count > 1 {
                            if uid.compare(seperatorArr[1]) == .orderedSame {
                                // Notify user for acknowlegement
                                if let fromUser = value["from"] {
                                    let alert = UIAlertController(title: TimerConstants.RequestTitle, message: "\(fromUser) wants to connect with you", preferredStyle: .alert)
                                    appDel.tempPlayingWith = User(name: fromUser, emailId: "", userId: seperatorArr[0])
                                    
                                    let yesAction = UIAlertAction(title: "YES", style: .default, handler: { (action) in
                                        
                                        appDel.playingWith = User(name: fromUser, emailId: "", userId: seperatorArr[0]) // passing email as "". Not useful.
                                        
                                       // move from "request" channel to "lock" channel
                                         let lock = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers + "/" + key)
                                         lock.setValue(value)
                                         let deleteReq = requestChannel.child(key)
                                         deleteReq.removeValue()
                                        // remove from "open" also if It is there.
                                        let openChannelUser1 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[0])")
                                        let openChannelUser2 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[1])")
                                        openChannelUser1.removeValue()
                                        openChannelUser2.removeValue()
                                        
                                        self.modeOfPlayLabel.text = "Acknowledgement Sent"
                                        PlayerManager.sharedInstance.isRequestSentByMe = false
                                        self.updatePlayerLabel()
                                    })
                                    let noAction = UIAlertAction(title: "NO", style: .default, handler: { (action) in
                                        // move from "request" channel to "open" channel
                                        if let delegate = UIApplication.shared.delegate as? AppDelegate {
                                            delegate.moveToOpenChannelBeforeChat()
                                        }
                                        // Delete from Request channel
                                        let deleteReq = requestChannel.child(key)
                                        deleteReq.removeValue()
                                        appDel.playingWith = nil
                                        PlayerManager.sharedInstance.isRequestSentByMe = false
                                    })
                                    alert.addAction(yesAction)
                                    alert.addAction(noAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                break
                            }
                        }
                    }
                }
            })
        }
    }
    
    //MARK:- Fetch Acknowlegment through Lock
    
    private func fetchLockUser() {
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate , let uid = appDel.loggedInUser?.userId  {
            // && PlayerManager.sharedInstance.modeOfPlay == .online
            
            let lockChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers)
            //retrieve request users
            lockChannel.observe(.value, with: { (snapShot) in
                if let dictionary = snapShot.value as? [String : [String : String]]  {
                    for (key,value) in dictionary {
                        // key is (UID of from User-UID of to User)
                        let seperatorArr = key.components(separatedBy: "-")
                        if seperatorArr.count > 1 && (uid.compare(seperatorArr[0]) == .orderedSame || uid.compare(seperatorArr[1]) == .orderedSame) {
                            if PlayerManager.sharedInstance.isRequestSentByMe { // if Player1
                                // Notify user for acknowlegement
                                if let toUser = value["to"] {
                                    let alert = UIAlertController(title: TimerConstants.AcknowledgeTitle, message: "\(toUser) connected with you", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.modeOfPlayLabel.text = "Connected"
                                        appDel.playingWith = User(name: toUser, emailId: "", userId: seperatorArr[1]) // passing email as "". Not useful.
                                        PlayerManager.sharedInstance.isRequestSentByMe = true
                                        self.updatePlayerLabel()
                                        self.startBlinkingAnimation(button: self.chatButton)
                                        
                                        // Remove from open, if any
                                        let openChannelUser1 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[0])")
                                        let openChannelUser2 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[1])")
                                        openChannelUser1.removeValue()
                                        openChannelUser2.removeValue()
                                        
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            } else { // if Player2
                                if let fromUser = value["from"] {
                                    let alert = UIAlertController(title: TimerConstants.AcknowledgeTitle, message: "\(fromUser) connected with you", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.modeOfPlayLabel.text = "Connected"
                                        appDel.playingWith = User(name: fromUser, emailId: "", userId: seperatorArr[0]) // passing email as "". Not useful.
                                        PlayerManager.sharedInstance.isRequestSentByMe = false
                                        self.updatePlayerLabel()
                                        self.startBlinkingAnimation(button: self.chatButton)
                                        
                                        // Remove from open, if any
                                        let openChannelUser1 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[0])")
                                        let openChannelUser2 = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/\(seperatorArr[1])")
                                        openChannelUser1.removeValue()
                                        openChannelUser2.removeValue()
                                        
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            self.playerLabel.text =   PlayerManager.sharedInstance.player.descriptionInString()
                            break
                        }
                    }
                }
            })
        }
         /*
        else if let appDel = UIApplication.shared.delegate as? AppDelegate , let uid = appDel.loggedInUser?.userId , PlayerManager.sharedInstance.modeOfPlay == .online , let playingWithId = appDel.playingWith?.userId {
            
        /* Response :
            [
                "from" : "A Laha",
                "to"   : "B Laha",
                "whoSend" : "UID of from/to",
                "isSingleMove" : "true/false",
                "toPoint" : "Integer_Number", // which one is triggered
                "fromPoint" : "Interger_Number", // Ignore for "Before Single move"
                "isSLCreated" : "true/false",
                "claimingPebble" : "Interger_Number"
            ]
        */
            
            if PlayerManager.sharedInstance.isRequestSentByMe {
                if PlayerManager.sharedInstance.player == .player1 {
                    self.tableViewInsideGameView.isUserInteractionEnabled = true
                    
                } else {
                    self.tableViewInsideGameView.isUserInteractionEnabled = false // Do not do anything , wait and watch
                    
                    // Pool what ever update made by "Player2"
                    // trigger the pebbles
                    
                    let lockChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers + "/" + "\(uid)-\(playingWithId)")
                    Parser.parseResponseWhileOnline(lockChannel: lockChannel, playingWithId: playingWithId)
                }
            } else {
                if PlayerManager.sharedInstance.player == .player2 {
                    self.tableViewInsideGameView.isUserInteractionEnabled = true
                } else {
                    self.tableViewInsideGameView.isUserInteractionEnabled = false // Do not so anything, wait and watch
                    // Pool what ever update made by "Player1"
                    // trigger the Pebbles
                    let lockChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers + "/" + "\(playingWithId)-\(uid)")
                    Parser.parseResponseWhileOnline(lockChannel: lockChannel, playingWithId: playingWithId)
                }
            }
        }
         */
    }
    
    private func deviceCheck() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if DeviceType.IS_IPHONE_4_OR_LESS {
                return false
            }
        }
        return true
    }
    
    //MARK:- Update after Sign In / Sign Out call 
    
    func addLabel() {
        if let label = self.playerLabel { // if present
            label.removeFromSuperview()
        }
        self.playerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 300, height: 21))
        self.playerLabel.text = PlayerManager.sharedInstance.player.descriptionInString()
        self.playerLabel.font = UIFont(name: "system", size: 15)
        self.playerLabel.textColor = UIColor.blue
        self.view.addSubview(playerLabel)
        
        if let label = modeOfPlayLabel { // if present remove it
            label.removeFromSuperview()
        }
        self.modeOfPlayLabel = UILabel(frame: CGRect(x: 300, y: 0, width: 300, height: 21))
        self.modeOfPlayLabel.text = PlayerManager.sharedInstance.modeOfPlay?.description()
        self.modeOfPlayLabel.textColor = UIColor.blue
        self.view.addSubview(modeOfPlayLabel)
    }
    
    func updatePlayerLabel() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate , let username = appDelegate.loggedInUser?.name {
            if PlayerManager.sharedInstance.modeOfPlay == .offline {
                player1Label.text = username
                player2Label.text = "Player2"
            } else if PlayerManager.sharedInstance.modeOfPlay == .withiOS {
                player1Label.text = username
                player2Label.text = "iOS"
            }
            /* update when play online
            else {
                if PlayerManager.sharedInstance.isRequestSentByMe {
                    player1Label.text = username
                    player2Label.text = appDelegate.playingWith?.name ?? "Player2"
                } else {
                    player1Label.text = appDelegate.playingWith?.name ?? "Player1"
                    player2Label.text = username
                }
            }
            */
        } else {
            player1Label.text = "Player1"
            player2Label.text = "Player2"
        }
    }
    
    //MARK:- needsSetDisplayForAllTableCell
    
    func needsSetDisplayForAllTableCell() {
        for i in 0...6 {
            if let cell = cellCreate(i, section: 0) {
                cell.setNeedsDisplay()
            }
        }
    }
    
    func cellCreate(_ row : Int, section : Int)-> UITableViewCell? {
        if let tableVw = tableViewInsideGameView  {
            return tableVw.cellForRow(at: IndexPath(row: row, section: section))
        }
        return nil
    }
    
    //MARK:- Setting
    
    @IBAction func Setting(_ sender: UIButton) {
        print("Setting is clicked")
    }
    
    //MARK:- Options
    
    @IBAction func optionsTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Play Mode", message: "", preferredStyle: .actionSheet)
        let offlineAction = UIAlertAction(title: "Offline", style: .default, handler: { (action) in
            PlayerManager.sharedInstance.modeOfPlay = .offline
            self.player2Label.text = "Player2"
        })
        let onlineAction = UIAlertAction(title: "Online( for Chat only )", style: .default, handler: { (action) in
            
            if let appDel = UIApplication.shared.delegate as? AppDelegate, let _ = appDel.loggedInUser {
                PlayerManager.sharedInstance.modeOfPlay = .online
            } else  {
                // ask for Sign In to the user
                self.showAlertWithTimer(title: "Alert", message: "First Sign In then Press on 'Online' to get online users", completionBlock: {
                    self.signInTapped(UIButton())
                })
            }
            self.player2Label.text = "Player2" // remove when online assignment has done
            //self.onlineTapped(UIButton())
        })
        let withiOS = UIAlertAction(title: "With iOS", style: .default, handler: { (action) in
            PlayerManager.sharedInstance.modeOfPlay = .withiOS
            self.player2Label.text = "iOS"
        })
        alertController.addAction(offlineAction)
        alertController.addAction(withiOS)
        alertController.addAction(onlineAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- How to Play 
    
    @IBAction func HowToPlayTheGame(_ sender: UIButton) {
        // Show the tutorials
        if let introductionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroductionPageVC") as? IntroductionPageVC {
            present(introductionVC, animated: true, completion: nil)
        }
    }

    
    //MARK:- ChatButton Tapped
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        
         self.stopBlinkingAnimation(button: self.chatButton)
        // If user is signed in and choose someone from Online then open the chat window
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let _ = appDelegate.loggedInUser , let _ = appDelegate.playingWith
        {
            if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                self.present(chatViewController, animated: true, completion: nil)
            }
        } else {
            if PlayerManager.sharedInstance.isRequestSentByMe {
                showAlertWithTimer(title: "Sorry!!!", message: "Wait For Acknowledgement")
            } else {
                showAlertWithTimer(title: "Sorry!!!", message: "Send a request to online user")
            }
        }
    }
    
    //MARK:- Who is Online
    
    @IBAction func onlineTapped(_ sender: UIButton) {
        
        // open a TableView, which will show "Acknowledge to play" and "Request to play" 
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate, let _ = appDel.loggedInUser {
            // PlayerManager.sharedInstance.modeOfPlay = .online // it will happen at "Acknowledge to play"
            
            if let onlineVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnlineViewController") as? OnlineViewController {
                present(onlineVC, animated: true, completion: nil)
                PlayerManager.sharedInstance.modeOfPlay = .online
                self.player2Label.text = "Player2"
            }
        } else {
            // ask for Sign In to the user 
            showAlertWithTimer(title: "Alert", message: "First Sign In then Press on 'Online' to get online users", completionBlock: {
                self.signInTapped(UIButton())
            })
        }
    }
    
    func showAlertWithTimer(title : String, message : String , completionBlock : (()-> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                alert.dismiss(animated: true, completion: {
                    completionBlock?()
                })
            })
        })
    }
    
    //MARK:- Sign In
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signInTapped(_ sender: UIButton) {
    
        let _ = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                // User is signed in.
                if let name = user.displayName, let email = user.email , let appDel = UIApplication.shared.delegate as? AppDelegate {
                    appDel.loggedInUser = User(name: name, emailId: email, userId: user.uid)
                    
                    // add user to Online Channel Database in FireBase
                    let onlineChannel  = appDel.ref.child(DataBaseConstants.OnlineChannel)
                    
                    // add them to Open group 
                    let openUsersChannel = onlineChannel.child(DataBaseConstants.OpenUsers+"/\(user.uid)")
                    let dict = [DataBaseConstants.name : name, DataBaseConstants.gmail : email]
                    openUsersChannel.setValue(dict)
                }
                // if google sign in page present, remove it 
                let appDel = UIApplication.shared.delegate as? AppDelegate
                if let controller = appDel?.window?.rootViewController as? BaseViewController {
                    if let presentedController = controller.presentedViewController as? GoogleSignInViewController {
                        presentedController.close(UIButton())
                    }
                }
                self.signOut.isHidden = false
                self.signInButton.isHidden = true
            } else {
                //intialize Google Sign In view Controller
                if let googleSignInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GoogleSignInViewController") as? GoogleSignInViewController {
                    self.present(googleSignInVC, animated: true, completion: nil)
                }
            }
            self.addLabel()
            self.updatePlayerLabel()
        })
    }
    
    //MARK:- Sign Out
    
    @IBOutlet weak var signOut: UIButton!
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        try? FIRAuth.auth()?.signOut()
        signInButton.isHidden = false
        signOut.isHidden = true
        if let appDel = UIApplication.shared.delegate as? AppDelegate  {
            appDel.clearAllDataRelatedWithLoggedInUser()
        }
    }
    
    //MARK:- Animate the image from position to another position for 2 secs 
    
    func animate(fromButton : Int , toButton : Int, completionBlock : (()-> Void)?) {
        if fromButton <= 24 && fromButton > 0 && toButton <= 24 && toButton > 0 && fromButton != toButton {
           
            let size = CGSize(width: AnimatedButtonSize.width, height: AnimatedButtonSize.height)
            
            // get cell then add co-ordinates with that 
            let fromCell = HelperClass.getCellWithButtonTag(fromButton)
            let toCell = HelperClass.getCellWithButtonTag(toButton)
            
            if let frame1 = fromCell?.frame, let frame2 = toCell?.frame {
                let newFromPosition = tableViewInsideGameView.convert(frame1, to: tableViewInsideGameView.superview)
                let newToPosition = tableViewInsideGameView.convert(frame2, to: tableViewInsideGameView.superview)
                
                var fromCenter = StoredPoints.centralCoordinates[fromButton]
                fromCenter.y += newFromPosition.origin.y
                var toCenter = StoredPoints.centralCoordinates[toButton]
                toCenter.y += newToPosition.origin.y
                
                let animatedView = UIView(frame: CGRect(origin: fromCenter, size: size))
                animatedView.backgroundColor = UIColor.brown
                self.view.addSubview(animatedView)
                
                UIView.animate(withDuration: TimerConstants.TimerDuration, delay: 0.0, options: .layoutSubviews, animations: {
                    self.tableViewInsideGameView.isUserInteractionEnabled = false
                    animatedView.frame = CGRect(origin: toCenter, size: size)
                    //animatedView.layoutIfNeeded()
                }, completion: { (complted) in
                    self.tableViewInsideGameView.isUserInteractionEnabled = true
                    animatedView.removeFromSuperview()
                    completionBlock?()
                })
            }
        }
    }
    
    
    //MARK:- Reset the Game
    
    func resetTheGame(){
        //            let baseVC = HelperClass.baseViewInstance
        //            DispatchQueue.main.asyncAfter(deadline: Double(2*NSEC_PER_SEC + 1) / Double(NSEC_PER_SEC), execute: {
        //
        //                //change the state , Color of Cell in table view and  save the color
        //
        //                baseVC.tableViewInsideGameView?.reloadData()
        //                PlayerManager.sharedInstance.player = CurrentPlayer.player1
        //                PebblesCount(p1Own: 9, p1Win: 0, p2Own: 9, p2Win: 0)
        //                StraightLineStatus.isStraightLineCreatedForPlayer1 = false
        //                StraightLineStatus.isStraightLineCreatedForPlayer2 = false
        //
        //                 // Reload the Collection View
        //            
        //            })
    }

    
}

//MARK:- BaseViewProtocol Delegate

extension BaseViewController : BaseViewProtocol {
    
    func showAlert(_ message: String, type: AlertType) {
        var title = "Title"
        switch type {
            case .congratulation : title = "Congratulation"
            case .alert: title = "Alert"
            case .win: title = "Win"
            case .deadLock : title = "Ohh !!!"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            if type == .win || type == .deadLock {
                exit(0)
            }
        }))
        
        switch type {
            case .congratulation: fallthrough
            case .deadLock : fallthrough
            case .alert: self.present(alert, animated: true, completion: nil)
            case .win :  self.present(alert, animated: true, completion: {
                // Reset the Game
                self.resetTheGame()
                let userDeafults = UserDefaults.standard
                if let score = userDeafults.value(forKey: UserDefaultsConstants.player1Score) as? Int {
                     self.player1Score.text = "\(score)"
                }
            })
        }
    }
    
    func showSingleMoveIntro() {
        if let singleMoveVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroScreenSingleMovement") as? IntroScreenSingleMovement{
            self.present(singleMoveVC, animated: true, completion: nil)
        }
    }
    
    func updatePebblesCount() {
        player1OwnPebbles.text = "\(PebblesCount.player1OwnPebblesCount)"
        player1ClaimingPebbles.text = "\(PebblesCount.player1WinningPebblesCount)"
        player2OwnPebbles.text = "\(PebblesCount.player2OwnPebblesCount)"
        player2ClaimimgPebbles.text = "\(PebblesCount.player2WinningPebblesCount)"
    }
    
    
    func showSingleMovementOptions(_ sender: PebbleButton) {
        self.currentButtonForOptions = sender
        // show in action sheet
        
        let alertController = UIAlertController(title: "Choose Option", message: "SINGLE MOVE", preferredStyle: .actionSheet)
        let left = UIAlertAction(title: "Left", style: .default, handler: { (action) in
            self.didSelect(Neighbor.left)
        })
        let right = UIAlertAction(title: "Right", style: .default, handler: { (action) in
            self.didSelect(Neighbor.right)
        })
        let top = UIAlertAction(title: "Top", style: .default, handler: { (action) in
            self.didSelect(Neighbor.top)
        })
        let bottom = UIAlertAction(title: "Bottom", style: .default, handler: { (action) in
            self.didSelect(Neighbor.down)
        })
        alertController.addAction(left)
        alertController.addAction(right)
        alertController.addAction(top)
        alertController.addAction(bottom)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func didSelect(_ option: Neighbor) {
        if let button = self.currentButtonForOptions{
            PlayerManager.sharedInstance.didSelect(option, button: button)
        }
    }
    
}

//MARK:- Blinking Animation on Chat Button

extension BaseViewController {
    
    func startBlinkingAnimation(button : UIButton) {
        if isChatButtonBlinking { return }
        isChatButtonBlinking = true
        
        // use basic animation 
        basicOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        basicOpacityAnimation.fromValue = 1.0
        basicOpacityAnimation.toValue = 0.0
        basicOpacityAnimation.duration = OpacityAnimationConstants.animationDuration
        basicOpacityAnimation.autoreverses = true
        basicOpacityAnimation.repeatDuration = OpacityAnimationConstants.repeatedDuration
        button.layer.add(basicOpacityAnimation, forKey: OpacityAnimationConstants.keyName)
    }
    
    func stopBlinkingAnimation(button : UIButton) {
        if !isChatButtonBlinking { return }
        isChatButtonBlinking = false
        button.layer.removeAllAnimations()
    }
}



