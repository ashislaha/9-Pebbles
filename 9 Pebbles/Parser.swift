//
//  Parser.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 05/12/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation
import Firebase

/* 
    This class and utilities are used for Online users are playing each other. Planning to do the same in next release.

 */

struct LockingResponse {
    var from            : String! = ""
    var to              : String! = ""
    var whoSend         : String  = ""
    var isSingleMove    : String! = "false"
    var toPoint         : String! = "-1"
    var fromPoint       : String! = "-1"
    var isSLCreated     : String! = "false"
    var claimingPebble  : String! = "-1"
}

// This class used for "online playing" 

class Parser {
    
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
    
    class func parseResponseWhileOnline(lockChannel : FIRDatabaseReference, playingWithId : String) {
        lockChannel.observe(.value, with: { (snapShot) in
            if let value = snapShot.value as? [String : String] {
                if let whoSend = value["whoSend"], whoSend.compare(playingWithId) == .orderedSame {
                    if let singleMove = value["isSingleMove"] , singleMove.compare("true") == .orderedSame {
                        // after Single Move starts
                        if let toPointStr = value["toPoint"] , let toPoint = Int(toPointStr), let fromPointStr = value["fromPoint"], let fromPoint = Int(fromPointStr) {
                            
                            if let isSLCreated = value["isSLCreated"] ,isSLCreated.compare("true") == .orderedSame {
                                if let claimimgPebbleStr = value["claimingPebble"], let claimingPebble = Int(claimimgPebbleStr) {
                                    PlayerManager.sharedInstance.singleMoveWhilePlayingOnline(frmoPoint: fromPoint, toPoint:toPoint,claimimgPebble: claimingPebble)
                                }
                            } else {
                                PlayerManager.sharedInstance.singleMoveWhilePlayingOnline(frmoPoint: fromPoint, toPoint:toPoint,claimimgPebble: nil)
                            }
                        }
                    } else { // Before Single Move Starts
                        if let positionStr = value["toPoint"] , let position = Int(positionStr) {
                            HelperClass.triggerButton(tag: position)
                            
                            // if SL is creted, then update the claimimg Pebble
                            if let isSLCreated = value["isSLCreated"] ,isSLCreated.compare("true") == .orderedSame {
                                if let claimimgPebbleStr = value["claimingPebble"], let claimingPebble = Int(claimimgPebbleStr) {
                                    HelperClass.triggerButton(tag: claimingPebble)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    class func sendResponse(lockChannel : FIRDatabaseReference ) {
        let dictionary = [
            "from" : PlayerManager.sharedInstance.response.from,
            "to"   : PlayerManager.sharedInstance.response.to,
            "whoSend" : PlayerManager.sharedInstance.response.whoSend,
            "isSingleMove" : PlayerManager.sharedInstance.response.isSingleMove,
            "toPoint" : PlayerManager.sharedInstance.response.toPoint,
            "fromPoint" : PlayerManager.sharedInstance.response.fromPoint,
            "isSLCreated" : PlayerManager.sharedInstance.response.isSLCreated,
            "claimingPebble" : PlayerManager.sharedInstance.response.claimingPebble
        ]
        lockChannel.setValue(dictionary)
    }
}
