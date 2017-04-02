//
//  HelperClass.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 21/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit


enum ModeOfPlay {
    case offline
    case online
    case withiOS
    
    func description() -> String {
        switch self {
        case .offline: return "Offline"
        case .online:  return "Online"
        case .withiOS: return "With iOS"
        }
    }
}

enum state : Int { // assocoate the state with button stateTag value
    case empty = 0
    case occupied
}
enum CurrentPlayer {
    case player1 // RED Color
    case player2 // GREEN Color
    func descriptionInString() -> String {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let player = appDelegate?.loggedInUser?.name ?? "Player1"
        //let playingWith = appDelegate?.playingWith?.name ?? "Player2"
        
        if PlayerManager.sharedInstance.modeOfPlay == .offline || PlayerManager.sharedInstance.modeOfPlay == .online {
            switch self {
            case .player1: return "Current Player : \(player)"
            case .player2: return "Current Player : Player2"
            }
        } else //if PlayerManager.sharedInstance.modeOfPlay == .withiOS
        {
            switch self {
            case .player1: return "Current Player : \(player)"
            case .player2: return "Current Player : Ashis Laha (CPU)"
            }
        }
        /* // online
        else { // if player sends "Request" then he/she is "player1" , else player accepts the req then he/she is "player2"
            if PlayerManager.sharedInstance.isRequestSentByMe {
                switch self {
                case .player1: return "Current Player : \(player)"
                case .player2: return "Current Player : \(playingWith)"
                }
            } else {
                switch self {
                case .player1: return "Current Player : \(playingWith)"
                case .player2: return "Current Player : \(player)"
                }
            }
        }
         */
    }
    
    func congratsMessage() -> String {
        switch self {
        case .player1: return "Congrats: Straight Line for Player1"
        case .player2: return "Congrats: Straight Line for Player2"
        }
    }
    
    func winningMessage() -> String {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let player = appDelegate?.loggedInUser?.name ?? "Player1"
        
        if PlayerManager.sharedInstance.modeOfPlay == .offline {
            switch self {
                case .player1: return "Game is OVER : Winning Player : \(player)"
                case .player2: return "Game is OVER : Winning Player : Player2"
            }
        } else {
            switch self {
            case .player1: return "Game is OVER : Winning Player : \(player)"
            case .player2: return "Game is OVER : Winning Player : CPU (Ashis Laha)"
            }
        }
    }
    
    func describe() -> String {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let player = appDelegate?.loggedInUser?.name ?? "Player1"
        let playingWith = appDelegate?.playingWith?.name ?? "Player2"
        
        if PlayerManager.sharedInstance.modeOfPlay == .online {
            // if player sends "Request" then he/she is "player1" , else player accepts the req then he/she is "player2"
            if PlayerManager.sharedInstance.isRequestSentByMe {
                switch self {
                case .player1: return "\(player)"
                case .player2: return "\(playingWith)"
                }
            } else {
                switch self {
                case .player1: return "\(playingWith)"
                case .player2: return "\(player)"
                }
            }
        }
        return player
    }
}

enum Neighbor {
    case left
    case right
    case top
    case down
}

enum AlertType {
    case congratulation
    case alert
    case win
    case deadLock
}

enum RectanglePosition {
    case leftMiddle
    case rightMiddle
    case topMiddle
    case buttomMiddle
    case central
    case leftTopCorner
    case rightTopCorner
    case leftBottmCorner
    case rightBottomCorner
}


struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct ColorConstants {
    static let colorForPlayer1 = UIColor.red
    static let colorForPlayer2 = UIColor.green
    static let defaultColor = UIColor.white
    static let straightlineColor = UIColor.cyan
}

struct StraightLineStatus {
    static var isStraightLineCreatedForPlayer1 : Bool = false
    static var isStraightLineCreatedForPlayer2 : Bool = false
}

struct UserDefaultsConstants{
    static let SingleMoveIntroScreenKey = "single move"
    static let player1Score = "Player1Score"
}

struct TableViewCellConstants {
    static let Cell1 = "Cell1"
    static let Cell2 = "Cell2"
    static let Cell3 = "Cell3"
    static let Cell4 = "Cell4"
    static let Cell5 = "Cell5"
    static let Cell6 = "Cell6"
    static let Cell7 = "Cell7"
}

struct DataBaseConstants {
    static let CommonChat       = "common-chats"
    static let ChatTermination  = "chat-termination"
    static let OnlineChannel    = "online-channel"
    static let OpenUsers        = "open"
    static let RequestUsers     = "request"
    static let LockedUsers      = "lock"
    
    static let name             = "name"
    static let gmail            = "gmail"
    static let userId           = "uid"
}

struct TimerConstants {

    static let TimerDuration : TimeInterval = 2.0 
    static let RequestTitle = "Please Acknowledge"
    static let AcknowledgeTitle = "Got Acknowledgement"
}

struct OpacityAnimationConstants {
    static let repeatedDuration = 10.0
    static let animationDuration = 0.5
    static let keyName = "ChangeOpacity"
}


extension UIColor {
    class func returnColorForPlayer(_ player : CurrentPlayer)-> UIColor{
        switch player {
        case .player1:
            return ColorConstants.colorForPlayer1
        case .player2:
            return ColorConstants.colorForPlayer2
        }
    }
    
    class func describe(_ color : UIColor)-> String {
        switch color {
        case ColorConstants.colorForPlayer1 :   return "player1"
        case ColorConstants.colorForPlayer2:    return "player2"
        case ColorConstants.defaultColor :      return "empty"
        default:
            return "NA"
        }
    }
}


struct PebblesCount {
    static var player1OwnPebblesCount       = 9
    static var player2OwnPebblesCount       = 9
    static var player1WinningPebblesCount   = 0
    static var player2WinningPebblesCount   = 0
    
    init( p1Own: Int, p1Win : Int, p2Own : Int , p2Win : Int){
        PebblesCount.player1OwnPebblesCount = p1Own
        PebblesCount.player1WinningPebblesCount = p1Win
        PebblesCount.player2OwnPebblesCount = p2Own
        PebblesCount.player2WinningPebblesCount = p2Win
    }
}

struct ColorManager {
    
    static var pebbleBackgroundColorArr = [UIColor.black] // 0th for black color
    init(){
        for _ in 1...24 {
            ColorManager.pebbleBackgroundColorArr.append(ColorConstants.defaultColor)
        }
    }
}

struct AnimatedButtonSize {
    static let width  : CGFloat = 22.0
    static let height : CGFloat = 22.0
}



//MARK:- Class HelperClass

class HelperClass {
    class var baseViewInstance : BaseViewController {
        get {
            let appDelegate = UIApplication.shared.delegate
            if let window = appDelegate?.window {
                if let baseVC = window?.rootViewController as? BaseViewController {
                    return baseVC
                }
            }
            return BaseViewController()
        }
    }
    
    class func getButton(_ tag : Int) -> PebbleButton {
        if let cell = getCellWithButtonTag(tag) {
            if let button = cell.contentView.viewWithTag(tag) as? PebbleButton {
                return button
                }
        }
        return PebbleButton()
    }
    
    class func getCellWithButtonTag(_ tag : Int) -> UITableViewCell? {
            let baseVC = HelperClass.baseViewInstance
            if let tableView = baseVC.tableViewInsideGameView {
                    var cell : UITableViewCell!
                    switch tag {
                    case 1...3:     cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                    case 4...6:     cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
                    case 7...9:     cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0))
                    case 10...15:   cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0))
                    case 16...18:   cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0))
                    case 19...21:   cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0))
                    case 22...24:   cell = tableView.cellForRow(at: IndexPath(row: 6, section: 0))
                    default:
                        break
                    }
                    return cell
                }
        return nil
    }
    
    // trigger button on tag , mainly used for playing "with iOS"
    
    class func triggerButton(tag : Int) {
        let baseVC = HelperClass.baseViewInstance
        if let tableView = baseVC.tableViewInsideGameView {
            switch tag {
                
            case 1...3:
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Cell1 {
                    switch tag {
                        case 1: cell.button1Tapped(getButton(tag))
                        case 2: cell.button2Tapped(getButton(tag))
                        case 3: cell.button3Tapped(getButton(tag))
                    default: break
                    }
                }
                
            case 4...6:
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? Cell2 {
                    switch tag {
                    case 4: cell.button4Tapped(getButton(tag))
                    case 5: cell.button5Tapped(getButton(tag))
                    case 6: cell.button6Tapped(getButton(tag))
                    default: break
                    }
                }
                
                
            case 7...9:
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? Cell3 {
                    switch tag {
                    case 7: cell.button7Tapped(getButton(tag))
                    case 8: cell.button8Tapped(getButton(tag))
                    case 9: cell.button9Tapped(getButton(tag))
                    default: break
                    }
                }
                
            case 10...15:
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? Cell4 {
                    switch tag {
                    case 10: cell.button10Tapped(getButton(tag))
                    case 11: cell.button11Tapped(getButton(tag))
                    case 12: cell.button12Tapped(getButton(tag))
                    case 13: cell.button13Tapped(getButton(tag))
                    case 14: cell.button14Tapped(getButton(tag))
                    case 15: cell.button15Tapped(getButton(tag))
                    default: break
                    }
                }
                
            case 16...18:
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? Cell5 {
                    switch tag {
                    case 16: cell.button16Tapped(getButton(tag))
                    case 17: cell.button17Tapped(getButton(tag))
                    case 18: cell.button18Tapped(getButton(tag))
                    default: break
                    }
                }
                
            case 19...21:
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? Cell6 {
                    switch tag {
                    case 19: cell.button19Tapped(getButton(tag))
                    case 20: cell.button20Tapped(getButton(tag))
                    case 21: cell.button21Tapped(getButton(tag))
                    default: break
                    }
                }
                
            case 22...24:
            
                if let cell = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as? Cell7 {
                    switch tag {
                    case 22: cell.button22Tapped(getButton(tag))
                    case 23: cell.button23Tapped(getButton(tag))
                    case 24: cell.button24Tapped(getButton(tag))
                    default: break
                    }
                }
                
            default:
                break
            }
        }
    }
    
    
    //MARK:-  Get Diff Coordinate of Button
    
    class func getCoordinate(_ tag : Int, position : RectanglePosition) -> CGPoint {
        let button = HelperClass.getButton(tag)
        switch position {
            case .leftMiddle:       return CGPoint(x: button.frame.origin.x, y: button.frame.midY)
            case .rightMiddle:      return CGPoint(x: button.frame.maxX, y: button.frame.midY)
            case .topMiddle:        return CGPoint(x: button.frame.midX, y: button.frame.origin.y)
            case .buttomMiddle:     return CGPoint(x: button.frame.midX, y: button.frame.maxY)
            case .central:          return CGPoint(x: button.frame.midX, y: button.frame.midY)
            case .rightTopCorner:   return CGPoint(x: button.frame.maxX, y: button.frame.origin.y)
            case .rightBottomCorner:return CGPoint(x: button.frame.maxX, y: button.frame.maxY)
            case .leftBottmCorner:  return CGPoint(x: button.frame.origin.x, y: button.frame.maxY)
            case .leftTopCorner:    return CGPoint(x: button.frame.origin.x, y: button.frame.origin.y)
        }
    }
}

//MARK:- Class StoredPoints

 class StoredPoints {
    
    static var rightMiddleCoordinates = [CGPoint.zero]
    static var leftMiddleCoordinates = [CGPoint.zero]
    static var topMiddleCoordinates = [CGPoint.zero]
    static var bottomMiddleCoordinates = [CGPoint.zero]
    static var centralCoordinates = [CGPoint.zero]
    static var leftTopCornerCoordinates = [CGPoint.zero]
    static var rightTopCornerCoordinates = [CGPoint.zero]
    static var leftBottomCoordinates = [CGPoint.zero]
    static var rightBottomCoordinates = [CGPoint.zero]
    
    class func calculatePoints() {
        for i in 1...24 {
            StoredPoints.rightMiddleCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.rightMiddle))
            StoredPoints.leftMiddleCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.leftMiddle))
            StoredPoints.topMiddleCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.topMiddle))
            StoredPoints.bottomMiddleCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.buttomMiddle))
            StoredPoints.centralCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.central))
            StoredPoints.leftTopCornerCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.leftTopCorner))
            StoredPoints.rightTopCornerCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.rightTopCorner))
            StoredPoints.leftBottomCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.leftBottmCorner))
            StoredPoints.rightBottomCoordinates.append(HelperClass.getCoordinate(i, position: RectanglePosition.rightBottomCorner))
        }
    }
}

extension StoredPoints {
    class func drawHorizontalLineBetweenButttons(fromButton : Int, toButton : Int) {
        for i in fromButton..<toButton {
            StoredPoints.drawLineBetweenTwoPoint(startPoint: StoredPoints.rightMiddleCoordinates[i], endPoint: StoredPoints.leftMiddleCoordinates[i+1])
        }
    }
    
    class func drawVerticalLines(cellIndex : Int, startButtontag : Int) {
        
        switch cellIndex {
        case 1:
                //Cell1, draw straight line from button to the end of the cell height
                let cell1 = HelperClass.baseViewInstance.cellCreate(0, section: 0) // cell1
                for i in startButtontag...startButtontag+2 {
                    StoredPoints.verticalLineFromBottomMiddle(cell: cell1!, buttonTag: i)
                }
        case 2:
            let cell2 = HelperClass.baseViewInstance.cellCreate(1, section: 0) // cell2
            for i in startButtontag...startButtontag+2 {
                StoredPoints.verticalLineFromBottomMiddle(cell: cell2!, buttonTag: i)
            }
            // do complete Straight line from 1 to 10
            let x = StoredPoints.bottomMiddleCoordinates[1].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell2!.frame.height))
            // Draw up from Button 5
            StoredPoints.drawLineBetweenTwoPoint(startPoint: StoredPoints.topMiddleCoordinates[5], endPoint:  CGPoint(x: StoredPoints.topMiddleCoordinates[5].x, y: 0))
             // do complete Straight line from 3 to 15
            let button3X = StoredPoints.bottomMiddleCoordinates[3].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell2!.frame.height))
            
        case 3:
            let cell3 = HelperClass.baseViewInstance.cellCreate(2, section: 0) // cell3
             StoredPoints.verticalLineFromBottomMiddle(cell: cell3!, buttonTag: 7)
             StoredPoints.verticalLineFromBottomMiddle(cell: cell3!, buttonTag: 9)
            
            // draw 1 to 10
            let x = StoredPoints.bottomMiddleCoordinates[1].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell3!.frame.height))
            // Draw up from Button 8
            StoredPoints.drawLineBetweenTwoPoint(startPoint: StoredPoints.topMiddleCoordinates[8], endPoint:  CGPoint(x: StoredPoints.topMiddleCoordinates[8].x, y: 0))
            // draw 3 to 15
            let button3X = StoredPoints.bottomMiddleCoordinates[3].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell3!.frame.height))
            
            // draw 4 to 11 
            let button4X = StoredPoints.bottomMiddleCoordinates[4].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button4X,y: 0), endPoint:  CGPoint(x: button4X, y: cell3!.frame.height))
            // draw 6 to 14 
            let button6X = StoredPoints.bottomMiddleCoordinates[6].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button6X,y: 0), endPoint:  CGPoint(x: button6X, y: cell3!.frame.height))
           
            
        case 4:
            
                let cell4 = HelperClass.baseViewInstance.cellCreate(3, section: 0) // cell4
                
                // draw 1 to 10
                let x = StoredPoints.bottomMiddleCoordinates[1].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell4!.frame.height/2))
                
                // draw 3 to 15
                let button3X = StoredPoints.bottomMiddleCoordinates[3].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell4!.frame.height/2))
                
                // draw 4 to 11
                let button4X = StoredPoints.bottomMiddleCoordinates[4].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button4X,y: 0), endPoint:  CGPoint(x: button4X, y: cell4!.frame.height/2))
                
                // draw 6 to 14
                let button6X = StoredPoints.bottomMiddleCoordinates[6].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button6X,y: 0), endPoint:  CGPoint(x: button6X, y: cell4!.frame.height/2))

                // draw 7 to 12
                let button7X = StoredPoints.bottomMiddleCoordinates[7].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button7X,y: 0), endPoint:  CGPoint(x: button7X, y: cell4!.frame.height/2))
            
                // draw 9 to 13
                let button9X = StoredPoints.bottomMiddleCoordinates[9].x
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button9X,y: 0), endPoint:  CGPoint(x: button9X, y: cell4!.frame.height/2))
            
            
                // draw 10 to 22
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: cell4!.frame.height/2), endPoint:  CGPoint(x: x, y: cell4!.frame.height))
                
                // draw 15 to 24
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: cell4!.frame.height/2), endPoint:  CGPoint(x: button3X, y: cell4!.frame.height))
                
                // draw 11 to 19
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button4X,y: cell4!.frame.height/2), endPoint:  CGPoint(x: button4X, y: cell4!.frame.height))
                
                // draw 14 to 21
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button6X,y: cell4!.frame.height/2), endPoint:  CGPoint(x: button6X, y: cell4!.frame.height))
                
                // draw 12 to 16
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button7X,y: cell4!.frame.height/2), endPoint:  CGPoint(x: button7X, y: cell4!.frame.height))
                
                // draw 13 to 18
                StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button9X,y: cell4!.frame.height/2), endPoint:  CGPoint(x: button9X, y: cell4!.frame.height))

            
        case 5:
            let cell5 = HelperClass.baseViewInstance.cellCreate(4, section: 0) // cell5
            // draw 10 to 22
            let x = StoredPoints.bottomMiddleCoordinates[1].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell5!.frame.height))
            
            // draw 15 to 24
            let button3X = StoredPoints.bottomMiddleCoordinates[3].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell5!.frame.height))
            
            // draw 11 to 19
            let button4X = StoredPoints.bottomMiddleCoordinates[4].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button4X,y: 0), endPoint:  CGPoint(x: button4X, y: cell5!.frame.height))
            
            // draw 14 to 21
            let button6X = StoredPoints.bottomMiddleCoordinates[6].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button6X,y: 0), endPoint:  CGPoint(x: button6X, y: cell5!.frame.height))
            
            // draw 12 to 16
            let button7X = StoredPoints.bottomMiddleCoordinates[7].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button7X,y: 0), endPoint:  CGPoint(x: button7X, y: cell5!.frame.height/2))
            
            // draw 13 to 18
            let button9X = StoredPoints.bottomMiddleCoordinates[9].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button9X,y: 0), endPoint:  CGPoint(x: button9X, y: cell5!.frame.height/2))
            
            // 17 -> 20 -> 23
            StoredPoints.verticalLineFromBottomMiddle(cell: cell5!, buttonTag: 17)

            
        case 6:
            let cell6 = HelperClass.baseViewInstance.cellCreate(5, section: 0) // cell6
            // draw 10 to 22
            let x = StoredPoints.bottomMiddleCoordinates[1].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell6!.frame.height))
            
            // draw 15 to 24
            let button3X = StoredPoints.bottomMiddleCoordinates[3].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell6!.frame.height))
            
            // draw 11 to 19
            let button4X = StoredPoints.bottomMiddleCoordinates[4].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button4X,y: 0), endPoint:  CGPoint(x: button4X, y: cell6!.frame.height/2))
            
            // draw 14 to 21
            let button6X = StoredPoints.bottomMiddleCoordinates[6].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button6X,y: 0), endPoint:  CGPoint(x: button6X, y: cell6!.frame.height/2))
            
            // 17 -> 20 -> 23
            StoredPoints.verticalLineFromBottomMiddle(cell: cell6!, buttonTag: 20)
            StoredPoints.verticalLineFromTopMiddle(cell: cell6!, buttonTag: 20)
            
        case 7:
            let cell7 = HelperClass.baseViewInstance.cellCreate(6, section: 0) // cell7
            // draw 10 to 22
            let x = StoredPoints.bottomMiddleCoordinates[1].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: x, y: 0), endPoint:  CGPoint(x: x, y: cell7!.frame.height/2))
            
            // draw 15 to 24
            let button3X = StoredPoints.bottomMiddleCoordinates[3].x
            StoredPoints.drawLineBetweenTwoPoint(startPoint: CGPoint(x: button3X, y: 0), endPoint:  CGPoint(x: button3X, y: cell7!.frame.height/2))
            
            // 17 -> 20 -> 23
            StoredPoints.verticalLineFromTopMiddle(cell: cell7!, buttonTag: 23)
           
        default:
            break
        }
    }
    
    class func verticalLineFromBottomMiddle(cell : UITableViewCell, buttonTag: Int) {
        let startPoint = StoredPoints.bottomMiddleCoordinates[buttonTag]
        let endPointY = cell.frame.height
        let endPoint = CGPoint(x: startPoint.x, y: endPointY)
        StoredPoints.drawLineBetweenTwoPoint(startPoint: startPoint, endPoint: endPoint)
    }
    class func verticalLineFromTopMiddle(cell : UITableViewCell, buttonTag: Int) {
        let startPoint = StoredPoints.topMiddleCoordinates[buttonTag]
        let endPoint = CGPoint(x: startPoint.x, y: 0)
        StoredPoints.drawLineBetweenTwoPoint(startPoint: startPoint, endPoint: endPoint)
    }
    
    class func drawLineBetweenTwoPoint(startPoint : CGPoint, endPoint : CGPoint ){
        let bezierPath = UIBezierPath()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)
        bezierPath.lineWidth = 2.0
        ColorConstants.straightlineColor.setStroke()
        bezierPath.stroke()
    }
}


