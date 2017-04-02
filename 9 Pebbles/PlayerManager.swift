//
//  Manager.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 29/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit


class PlayerManager : NSObject {
    
    static let sharedInstance: PlayerManager = { PlayerManager() }()
    
    var player : CurrentPlayer! { // always give you the current player
        didSet{
            self.setPlayerDescription()
            
            /*
            if modeOfPlay == .online { // Decide what you are, Player1 or Player2, wait until the opponent player did the move, update the same in UI both console
                if isRequestSentByMe { // then Player1 is YOU
                    if player == .player2 {
                         // Push the update of Player1 to back-end from Here
                        if let appDel = UIApplication.shared.delegate as? AppDelegate , let loggedUser = appDel.loggedInUser, let playingWith = appDel.playingWith, let uid = appDel.loggedInUser?.userId, let playingWithId = appDel.playingWith?.userId {
                            response.from = loggedUser.name ?? ""
                            response.to = playingWith.name ?? ""
                            response.whoSend = loggedUser.userId ?? ""
                            response.isSingleMove = isStillHavingOwnPebbles(player) ? "false" : "true"
                            
                            // create the reference 
                            let lockChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers + "/" + "\(uid)-\(playingWithId)")
                            Parser.sendResponse(lockChannel: lockChannel)
                        }
                    }
                
                } else { // Player2 is YOU
                    if player == .player1 {
                        // Push the update of Player2 to back-end from Here
                        // create the reference
                        if let appDel = UIApplication.shared.delegate as? AppDelegate , let loggedUser = appDel.loggedInUser, let playingWith = appDel.playingWith, let uid = appDel.loggedInUser?.userId, let playingWithId = appDel.playingWith?.userId {
                            response.from = playingWith.name ?? ""
                            response.to = loggedUser.name ?? ""
                            response.whoSend = loggedUser.userId ?? ""
                            response.isSingleMove = isStillHavingOwnPebbles(player) ? "false" : "true"
                            
                            // create the reference
                            let lockChannel = appDel.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers + "/" + "\(playingWithId)-\(uid)")
                            Parser.sendResponse(lockChannel: lockChannel)
                        }
                    }
                
                }
                
            } else  */
 
            if player == .player2 && modeOfPlay == .withiOS {
                
                // disable the user interaction of the table view
                if let baseVC = self.baseViewDelegate as? BaseViewController {
                    baseVC.tableViewInsideGameView.isUserInteractionEnabled = false
                }
                
                if isStillHavingOwnPebbles(self.player) { // Before Single move
                    let position = LearningAlgorithmBeforeSingleMove.sharedInstance.determinePosition()
                    HelperClass.triggerButton(tag: position)
                } else { //when single movement starts
                    let position :(fromPoint : Int, toPoint : Int) = LearningAlgorithmWhenSingleMoveStart.sharedInstance.determinePosition()
                    self.singleMoveWhilePlayingWithiOS(frmoPoint: position.fromPoint, toPoint: position.toPoint)
                }
            } else {
                // enable the user interaction of the table view
                if let baseVC = self.baseViewDelegate as? BaseViewController {
                    baseVC.tableViewInsideGameView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    var response : LockingResponse = LockingResponse()
    var modeOfPlay : ModeOfPlay? = .offline // default value  
    {
        didSet {
                modeOfPlayDescription()
        }
    }
    func modeOfPlayDescription() {
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            if let baseVC = appDel.window?.rootViewController as? BaseViewController {
                 baseVC.modeOfPlayLabel?.text = modeOfPlay?.description()
            }
        }
    }
    
    // variables for determining DeadLock Condition happens or not
    
    var isOnDeadlockCondition = false
    var player1PebblesOnBoard = [Int]() {
        didSet {
            // update player1StraightLine
            player1StraightLine = updatePlayerStraightLine(arr : player1PebblesOnBoard)
        }
    }
    var player2PebblesOnBoard = [Int]() {
        didSet {
            // update player2StraightLine
            player2StraightLine = updatePlayerStraightLine(arr : player2PebblesOnBoard)
        }
    }
    
    // Track the created straight Line
    var player1StraightLine = [[Int]]()
    var player2StraightLine = [[Int]]()
    
    // Track the player when online 
    // If player sends the request then he/she is considered as "player1" , if he/she acknowledge the req, then he/she is "player2"
    var isRequestSentByMe : Bool = false
    
    // Delegates variables
    var baseViewDelegate : BaseViewProtocol?
    
    func setPlayerDescription() {
        if let baseVc = self.baseViewDelegate as? BaseViewController {
            baseVc.playerLabel.text = player.descriptionInString()
        }
    }

    //MARK:- Color The Pebble 
    
    func colorThePebbleOnButtonTapped(_ sender : AnyObject, delegate : BaseViewProtocol) {
        
        self.baseViewDelegate = delegate
        
        // check the status of the StraightLine creation
        if StraightLineStatus.isStraightLineCreatedForPlayer2 {
            if self.claimingThePebble(.player2, claimingPebble: sender) { // Player2 is claiming a pebble to Player1
                if !self.isOnDeadlockCondition {
                    delegate.updatePebblesCount()
                    StraightLineStatus.isStraightLineCreatedForPlayer2 = false
                    self.gameOverCheck()
                    self.toggleCurrentPlayer(self.player)
                    self.setPlayerDescription()
                }
            } else {
                let message = "Player2 is claiming a pebble to Player1. Do it now"
                self.baseViewDelegate?.showAlert(message, type:AlertType.congratulation)
            }
            return
        } else if  StraightLineStatus.isStraightLineCreatedForPlayer1 {
            if self.claimingThePebble(.player1, claimingPebble: sender){ // Player1 is claiming a pebble to Player2
                if !self.isOnDeadlockCondition {
                    delegate.updatePebblesCount()
                    StraightLineStatus.isStraightLineCreatedForPlayer1 = false
                    self.gameOverCheck()
                    self.toggleCurrentPlayer(self.player)
                    self.setPlayerDescription()
                }
            }else{
                let message = "Player1 is claiming a pebble to Player2. Do it now"
                self.baseViewDelegate?.showAlert(message, type:AlertType.congratulation)
            }
            return
        }
        
        if isStillHavingOwnPebbles(self.player) {
            if let button = sender as? PebbleButton {
                if !self.colorThePebble(self.player, sender : button) {
                    let message = "Warning : This is OCCUPIED"
                    self.baseViewDelegate?.showAlert(message, type:AlertType.alert)
                } else {
                    
                    if player == .player1 {
                         player1PebblesOnBoard.append(button.tag )
                    } else {
                         player2PebblesOnBoard.append(button.tag )
                    }
                    
                     response.toPoint = "\(button.tag)"
                    if self.straightLineMatch(sender) {
                        response.isSLCreated = "true"
                        self.computationAfterStraightLineMatch(sender)
                    } else {
                        response.isSLCreated = "false"
                        self.toggleCurrentPlayer(player)
                        
                    }
                }
            }
        } else {
            singleMovement(sender)
        }
        delegate.updatePebblesCount()
    }
    
    
    private func gameOverCheck() {
        //Check the termination condition for GAME
        if terminateWithWinningPebbleCount(player){
            //set the score
            var scoreValue : Int!
            if player == .player1 {
                scoreValue = 9 - PebblesCount.player2WinningPebblesCount
            } else {
                scoreValue = PebblesCount.player1WinningPebblesCount - 9
            }
            let userDeafults = UserDefaults.standard
            userDeafults.set(scoreValue, forKey: UserDefaultsConstants.player1Score)
            
            let message = player.winningMessage()
            self.baseViewDelegate?.showAlert(message, type:AlertType.win)
        }
    }
    
    private func singleMovement(_ sender : AnyObject) {
        // When all own pebbles are covered
        // You can move only one position if the position is empty
        // check the current pebble has been tapped or not
        // Show an Intro Screen for awareness of Single movement
        
        if let button = sender as? PebbleButton {
            let userDefault = UserDefaults.standard
            if let oneTimeIntroShow = userDefault.object(forKey: UserDefaultsConstants.SingleMoveIntroScreenKey) as? Bool , oneTimeIntroShow == true {
                self.baseViewDelegate?.showSingleMoveIntro()
                return
            }
            if button.backgroundColor == ColorConstants.defaultColor {
                let message = "Warning : You Tapped an EMPTY position for Single Move"
                self.baseViewDelegate?.showAlert(message, type: .alert)
                return
            }
            else if getColor(player) != button.backgroundColor { // Give a warning
                let message = "Warning : You Tapped opposition Pebble for Single Move"
                self.baseViewDelegate?.showAlert(message, type: .alert)
                return
            }
        }
        moveOnePosition(sender)
    }

    private func toggleCurrentPlayer(_ player:CurrentPlayer){
        switch player {
        case .player1:
            self.player = CurrentPlayer.player2
        case .player2:
            self.player = CurrentPlayer.player1
        }
    }
    
    private func isStillHavingOwnPebbles(_ player: CurrentPlayer) -> Bool {
        switch player {
        case .player1 :
            return PebblesCount.player1OwnPebblesCount > 0
        case .player2 :
            return PebblesCount.player2OwnPebblesCount > 0
        }
    }
    
    private func terminateWithWinningPebbleCount(_ player: CurrentPlayer) -> Bool {
        switch player {
        case .player1 :
            return PebblesCount.player1WinningPebblesCount >= 7
        case .player2 :
            return PebblesCount.player2WinningPebblesCount >= 7
        }
    }
    
    private func colorThePebble(_ player: CurrentPlayer, sender : AnyObject) -> Bool {
        var isSuccess = false
        if let button = sender as? PebbleButton {
            // check the state whether it is empty or occupied
            if button.stateTag == state.empty.rawValue {
                switch player {
                case .player1:
                    button.backgroundColor = UIColor.returnColorForPlayer(.player1)
                    PebblesCount.player1OwnPebblesCount -= 1
                case .player2:
                    button.backgroundColor = UIColor.returnColorForPlayer(.player2)
                    PebblesCount.player2OwnPebblesCount -= 1
                }
                button.stateTag = state.occupied.rawValue //1
                self.saveColor(button.tag, color: button.backgroundColor!)
               // self.toggleCurrentPlayer(self.player)
                isSuccess = true
            } else { // occupied then show the warning message
                isSuccess = false
            }
        }
        return isSuccess
    }

    
    //MARK:- Move One Position
    
    private func moveOnePosition(_ sender : AnyObject) {
        // First tap on a button 
        // take the options for direction 
        // move to 1 position if it is empty else make a warning message 
        
        if let button = sender as? PebbleButton {
            response.fromPoint = "\(button.tag)"
            self.baseViewDelegate?.showSingleMovementOptions(button)
        }
    }
    
    func didSelect(_ option: Neighbor, button : PebbleButton) {
        // Simple just check the availabilty and move it
        var point : Int?
        
        switch option {
            case .left:  point = horizontalLeft(button)
            case .right: point = horizontalRight(button)
            case .top:   point = verticalUp(button)
            case .down:  point = verticalDown(button)
        }
        
        if let point = point {
            if point != -1 && getColor(point) == ColorConstants.defaultColor {
                validSingleMove(fromButton: button, toPoint: point)
            } else {
                // Show alert message 
                let message = "WARNING : This is not a valid SINGLE move"
                self.baseViewDelegate?.showAlert(message, type: .alert)
            }
        }
    }
    
    private func validSingleMove(fromButton : PebbleButton, toPoint : Int, claimingPebble : Int? = nil) {
        
        response.fromPoint = "\(fromButton.tag)"
        response.toPoint = "\(toPoint)"
        
        self.baseViewDelegate?.animate(fromButton: fromButton.tag, toButton: toPoint, completionBlock: {
            self.updatePebblesOnBoard(removeItem: fromButton.tag, addItem: toPoint)
            
            // allocate the current player color to that location
            let targetButton = HelperClass.getButton(toPoint)
            targetButton.backgroundColor = self.getColor(self.player)
            self.saveColor(toPoint, color: self.getColor(self.player))
            targetButton.stateTag = state.occupied.rawValue
            
            // clear the color for current button
            fromButton.backgroundColor = ColorConstants.defaultColor
            self.saveColor(fromButton.tag, color:ColorConstants.defaultColor)
            fromButton.stateTag = state.empty.rawValue
            
            //check the straightLine creation or not
            if self.straightLineMatch(targetButton) {
                self.computationAfterStraightLineMatch(targetButton,claimingPebble:claimingPebble)
            }else {
                self.toggleCurrentPlayer(self.player)
            }
        })
    }
    
    //MARK:- Single Move when playing withiOS
    
    func singleMoveWhilePlayingWithiOS(frmoPoint : Int, toPoint : Int, claimimgPebble : Int? = nil ) {
        let button = HelperClass.getButton(frmoPoint)
        validSingleMove(fromButton: button, toPoint: toPoint,claimingPebble: claimimgPebble)
        self.baseViewDelegate?.updatePebblesCount()
        if modeOfPlay == .withiOS {
            self.baseViewDelegate?.showAlertWithTimer(title: "iOS : Single Move", message: "Moving from \(frmoPoint) to \(toPoint)", completionBlock: nil)
            
        } else if modeOfPlay == .online {
            self.baseViewDelegate?.showAlertWithTimer(title: "Single Move", message: "Moving from \(frmoPoint) to \(toPoint)", completionBlock: nil)
        }
    }
    
    //MARK:- Single Move when playing Online
    
    func singleMoveWhilePlayingOnline(frmoPoint : Int, toPoint : Int, claimimgPebble : Int?) {
        singleMoveWhilePlayingWithiOS(frmoPoint: frmoPoint, toPoint: toPoint, claimimgPebble: claimimgPebble)
    }
    
    
    private func updatePebblesOnBoard(removeItem : Int , addItem : Int) {
        if player == .player1 {
            if let index = player1PebblesOnBoard.index(of: removeItem) {
                player1PebblesOnBoard.remove(at: index)
                player1PebblesOnBoard.append(addItem)
            }
        } else {
            if let index = player2PebblesOnBoard.index(of: removeItem) {
                player2PebblesOnBoard.remove(at: index)
                player2PebblesOnBoard.append(addItem)
            }
        }
    }

    
    //MARK:- calculate the Straight Line Matching
    
    private func straightLineMatch(_ sender : AnyObject) -> Bool {
        
        // find out the color of 4-Neighbor
        if let button = sender as? PebbleButton {
            let leftPoint = horizontalLeft(button)
            let rightPoint = horizontalRight(button)
            let topPoint = verticalUp(button)
            let downPoint = verticalDown(button)
            
            if button.backgroundColor != ColorConstants.defaultColor {
                
                // Horizontal check
                if leftPoint != -1 && rightPoint != -1 { // button is middle point
                    if button.backgroundColor! == getColor(leftPoint) && button.backgroundColor! == getColor(rightPoint){
                        return true
                    }
                } else if rightPoint != -1 { // button is left point
                    if button.backgroundColor! == getColor(rightPoint) &&  getColor(rightPoint) == getColor(neighborPoint(rightPoint, neighbor: .right)) {
                        return true
                    }
                    
                } else if leftPoint != -1 { // button is right point
                    if button.backgroundColor! == getColor(leftPoint) &&  getColor(leftPoint) == getColor(neighborPoint(leftPoint, neighbor: .left)) {
                        return true
                    }
                }
                
                //Vertical check
                if topPoint != -1 && downPoint != -1 { // button is middle point
                    if button.backgroundColor! == getColor(topPoint) && button.backgroundColor! == getColor(downPoint) {
                        return true
                    }
                } else if downPoint != -1 { // button is top point
                    if button.backgroundColor! == getColor(downPoint) &&  getColor(downPoint) == getColor(neighborPoint(downPoint, neighbor: .down)) {
                        return true
                    }
                    
                } else if topPoint != -1 { // button is down point
                    if button.backgroundColor! == getColor(topPoint) &&  getColor(topPoint) == getColor(neighborPoint(topPoint, neighbor: .top)) {
                        return true
                    }
                }
            }
        }
        return false
    }
    

    func computationAfterStraightLineMatch(_ sender: AnyObject, claimingPebble : Int? = nil ){
        
        if let button = sender as? PebbleButton {
            switch button.backgroundColor! {
            case ColorConstants.colorForPlayer1: //player 1
                StraightLineStatus.isStraightLineCreatedForPlayer1 = true
                break
            case ColorConstants.colorForPlayer2: // player 2
                StraightLineStatus.isStraightLineCreatedForPlayer2 = true
                break
            default:
                break
            }
        }
        
       
            let message = "A Straight Line is CREATED, a pebble will be claimed from Opposition."
            if self.player == .player2 && self.modeOfPlay == .withiOS {
                if PlayerManager.sharedInstance.isStillHavingOwnPebbles(self.player) {
                    // show the message
                    self.baseViewDelegate?.showAlertWithTimer(title: "Great!!", message: message, completionBlock: {
                        self.triggerButtonForClaimingPebblesWithiOS()
                    })
                } else { // when single move starts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.baseViewDelegate?.showAlertWithTimer(title: "Great!!", message: message, completionBlock: {
                            self.triggerButtonForClaimingPebblesWithiOS()
                        })
                    })
                }
            }
            /*
            else if self.modeOfPlay == .online {
                self.baseViewDelegate?.showAlertWithTimer(title: "Great!!", message: message, completionBlock: {
                    if let clamingPebble = claimingPebble {
                        HelperClass.triggerButton(tag: clamingPebble)
                    }
                })
            } 
            */
            else {
                self.baseViewDelegate?.showAlert(message, type:AlertType.congratulation)
            }
            // update the label message
            if let baseVc = self.baseViewDelegate as? BaseViewController {
                baseVc.playerLabel.text = self.player.congratsMessage()
            }
    }
    
    private func triggerButtonForClaimingPebblesWithiOS(){
        
        let position = LearningAlgorithmBeforeSingleMove.sharedInstance.claimThePebbleWhilePlayingWithiOS()
        HelperClass.triggerButton(tag: position)
    }
    
    //MARK:- claimingThePebble
    
    func claimingThePebble(_ player: CurrentPlayer, claimingPebble : AnyObject)-> Bool {
        
        // Claim the pebble from opposition but the pebble must not belong to a straight line
        
        var isClaimSuccess = false
        if let button = claimingPebble as? PebbleButton {
            // retrieve the background color
            let backgroundColor = button.backgroundColor
            var claimingPebbleAssociatedPlayer : CurrentPlayer!
            if backgroundColor == ColorConstants.colorForPlayer2 || backgroundColor == ColorConstants.colorForPlayer1 {
                if backgroundColor == ColorConstants.colorForPlayer1 { // Player 1
                    claimingPebbleAssociatedPlayer = CurrentPlayer.player1
                }
                else if backgroundColor == ColorConstants.colorForPlayer2{ // player 2
                    claimingPebbleAssociatedPlayer = CurrentPlayer.player2
                }
            }
            
            // Check whether any deadlock is occured or not
            
            if deadLock(currentPlayer: player) {
                isOnDeadlockCondition = true
                let message = "OPPS !!!! It's a DEADLOCK. MATCH DRAW !!!! GAME OVER."
                self.baseViewDelegate?.showAlert(message, type:AlertType.deadLock)
                return true
            }
            
            if (player != claimingPebbleAssociatedPlayer) { //claim only to opposite pebble
                
                // Check the pebble position, must not be in a straight line
                if straightLineMatch(claimingPebble) {
                    let message = "Warning : You cannot claim a pebble which belongs to a straight line."
                    self.baseViewDelegate?.showAlert(message, type:AlertType.alert)
                    return false
                }
                
                if backgroundColor == ColorConstants.colorForPlayer1 { // Player2 is claiming to player1
                    // make some calculation, update the Winning pebble count
                    PebblesCount.player2WinningPebblesCount += 1
                    if let index = player1PebblesOnBoard.index(of: button.tag) {
                        player1PebblesOnBoard.remove(at: index)
                    }
                    response.claimingPebble = "\(button.tag)"
                    isClaimSuccess = true
                    response.isSLCreated = "true"
                }
                else if backgroundColor == ColorConstants.colorForPlayer2 { // Player1 is claiming to player2
                    // make some calculation, update the Winning pebble count
                    PebblesCount.player1WinningPebblesCount += 1
                    if let index = player2PebblesOnBoard.index(of: button.tag) {
                        player2PebblesOnBoard.remove(at: index)
                    }
                    response.claimingPebble = "\(button.tag)"
                    isClaimSuccess = true
                    response.isSLCreated = "true"
                }
                button.backgroundColor = ColorConstants.defaultColor
                self.saveColor(button.tag, color: button.backgroundColor!)
                button.stateTag = state.empty.rawValue
            } else {
                //cannot claim to same side
                let message = "Warning : You must claim a pebble from Opposition."
                self.baseViewDelegate?.showAlert(message, type:AlertType.alert)
            }
        }
        return isClaimSuccess
    }
    

    func deadLock(currentPlayer: CurrentPlayer)-> Bool {
        // check whether any deadlock happens or not 
        // When you claim the pebble from opposition, but all points belongs to the straight line.
        // So check all the pebbles of other player.
        // check all the points associated with theOtherPlayer 
        
        var noDeadlocak = [Int]()
        if currentPlayer == .player1 {
            noDeadlocak = player2PebblesOnBoard.filter({ !belongsToStraightLine(buttonTag: $0) })
        } else {
            noDeadlocak = player1PebblesOnBoard.filter({ !belongsToStraightLine(buttonTag: $0) })
        }
        return !(noDeadlocak.count > 0)
    }
    
    func belongsToStraightLine(buttonTag : Int) -> Bool {
        if buttonTag != -1 {
            let targetButton = HelperClass.getButton(buttonTag)
            return straightLineMatch(targetButton)
        }
        return false
    }
    
    //MARK:- Neighbor-4
    
    func horizontalLeft(_ sender : AnyObject) -> Int {
        if let button = sender as? PebbleButton {
            if button.currentTitle != nil {
                if let point = Int(button.currentTitle!) {
                    return neighborPoint(point, neighbor: .left)
                }
            }
        }
        return -1
    }
    
    func horizontalRight(_ sender : AnyObject) -> Int {
        if let button = sender as? PebbleButton {
            if button.currentTitle != nil {
                if let point = Int(button.currentTitle!) {
                    return neighborPoint(point, neighbor: .right)
                }
            }
        }
        return -1
    }
    
    func verticalUp(_ sender : AnyObject) -> Int { // Hard core value
        if let button = sender as? PebbleButton {
            if button.currentTitle != nil {
                if let point = Int(button.currentTitle!) {
                    return neighborPoint(point, neighbor: .top)
                }
            }
        }
        return -1
    }
    
    func verticalDown(_ sender : AnyObject) -> Int { // Hard core value
        if let button = sender as? PebbleButton {
            if button.currentTitle != nil {
                if let point = Int(button.currentTitle!) {
                    return neighborPoint(point, neighbor: .down)
                }
            }
        }
        return -1
    }
    
    func neighborPoint(_ point : Int, neighbor : Neighbor) -> Int{
        switch neighbor {
        case .left:
            if (point-1)%3 != 0 {
                return point-1
            }else{
                return -1
            }
            
        case .right:
            if (point)%3 != 0 {
                return point+1
            }else{
                return -1
            }
        case .top:
            switch point {
            case 1,2,3,4,6,7,9,17: return -1
            case 10: return 1
            case 22: return 10
            case 11: return 4
            case 19: return 11
            case 5:  return 2
            case 8:  return 5
            case 12: return 7
            case 16: return 12
            case 23: return 20
            case 20: return 17
            case 13: return 9
            case 18: return 13
            case 14: return 6
            case 21: return 14
            case 15: return 3
            case 24: return 15
            default:
                return -1
            }
        case .down:
            switch point {
            case 8,16,18,19,21,22,23,24: return -1
            case 1: return 10
            case 2: return 5
            case 3: return 15
            case 4: return 11
            case 5: return 8
            case 6: return 14
            case 7: return 12
            case 9: return 13
            case 10: return 22
            case 11: return 19
            case 12: return 16
            case 13: return 18
            case 14: return 21
            case 15: return 24
            case 17: return 20
            case 20: return 23
            default:
                return -1
            }
        }
    }

    func updatePlayerStraightLine(arr : [Int] ) -> [[Int]] {
        if arr.count > 2 {
            let set = Set(arr)
            var results = [[Int]]()
            if Set(HorizontalStraightLines.H1).isSubset(of: set) {
                results.append(HorizontalStraightLines.H1)
            }
            if Set(HorizontalStraightLines.H2).isSubset(of: set) {
                results.append(HorizontalStraightLines.H2)
            }
            if Set(HorizontalStraightLines.H3).isSubset(of: set) {
                results.append(HorizontalStraightLines.H3)
            }
            if Set(HorizontalStraightLines.H4).isSubset(of: set) {
                results.append(HorizontalStraightLines.H4)
            }
            if Set(HorizontalStraightLines.H5).isSubset(of: set) {
                results.append(HorizontalStraightLines.H5)
            }
            if Set(HorizontalStraightLines.H6).isSubset(of: set) {
                results.append(HorizontalStraightLines.H6)
            }
            if Set(HorizontalStraightLines.H7).isSubset(of: set) {
                results.append(HorizontalStraightLines.H7)
            }
            if Set(HorizontalStraightLines.H8).isSubset(of: set) {
                results.append(HorizontalStraightLines.H8)
            }
            if Set(VerticalStraightLines.V1).isSubset(of: set){
                results.append(VerticalStraightLines.V1)
            }
            if Set(VerticalStraightLines.V2).isSubset(of: set){
                results.append(VerticalStraightLines.V2)
            }
            if Set(VerticalStraightLines.V3).isSubset(of: set){
                results.append(VerticalStraightLines.V3)
            }
            if Set(VerticalStraightLines.V4).isSubset(of: set){
                results.append(VerticalStraightLines.V4)
            }
            if Set(VerticalStraightLines.V5).isSubset(of: set){
                results.append(VerticalStraightLines.V5)
            }
            if Set(VerticalStraightLines.V6).isSubset(of: set){
                results.append(VerticalStraightLines.V6)
            }
            if Set(VerticalStraightLines.V7).isSubset(of: set){
                results.append(VerticalStraightLines.V7)
            }
            if Set(VerticalStraightLines.V8).isSubset(of: set){
                results.append(VerticalStraightLines.V8)
            }
            return results
            
        } else {
            return [[Int]]()
        }
    }
    
    //MARK:- Maintain BackGround color Database
    
    func saveColor(_ value : Int, color : UIColor){
        if value > 0 &&  value <= 24 {
            ColorManager.pebbleBackgroundColorArr[value] = color
        }
    }
    
    func getColor(_ value : Int) -> UIColor{
        if value > 0 && value <= 24 {
            return ColorManager.pebbleBackgroundColorArr[value]
        }
        return UIColor.black
    }
    
    func getColor(_ player:CurrentPlayer)-> UIColor {
        switch player {
            case .player1:  return ColorConstants.colorForPlayer1
            case .player2:  return ColorConstants.colorForPlayer2
        }
    }
 }
 


