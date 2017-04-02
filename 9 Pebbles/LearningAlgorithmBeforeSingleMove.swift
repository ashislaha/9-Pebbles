//
//  LearningAlgorithmBeforeSingleMove.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 04/06/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit


class LearningAlgorithmBeforeSingleMove {
    
    /* How to train the computer when putting the pebble before all 9 pebbles covered.
    
    Strategies :-
     Consider the basic rules :- 
     1. If you have any valid Straight line which is in opening mode, complete it.
     2. block the user when trying to create the straight line
     3. When claiming try to claim in a way so that you will get more benefit and opposition will strugle to create another straight line
     4. Consider the state in an instance and give it to the algo and it will decide and decides the proper position to opt for you.
     */

    
    static let sharedInstance: LearningAlgorithmBeforeSingleMove = { LearningAlgorithmBeforeSingleMove() }()
    
    
    
    //MARK:- Position Determination
    // determine the tag of the button (position) and trigger the button
    // Input Player1 pebbles on board [point] & Player2 pebbles on board [Point]
    // player1PebblesOnBoard & player2PebblesOnBoard
    // We assume that "Player2" is the computer
    // X = set of player1 pebbles , Y = set of player2 pebbles
    
    func determinePosition()->Int {
       
        
        print(PlayerManager.sharedInstance.player1PebblesOnBoard)
        print(PlayerManager.sharedInstance.player2PebblesOnBoard)
        
        //case 1 : check the positions whether any possible for straight line is there or not for CPU
        let position = openForStraightLineToCPU()
        if  position != -1 {
            return position
        }
        
        
        //case 2: check whether opposiotion is creating a strtaight line , block the position
        
        if PlayerManager.sharedInstance.player1PebblesOnBoard.count >= 2 {
            for i in 0...PlayerManager.sharedInstance.player1PebblesOnBoard.count-2 {
                for j in i+1...PlayerManager.sharedInstance.player1PebblesOnBoard.count-1 {
                    
                     // skip if both points belongs to a straight line created by Player1
                    if LearningHelper.shared.isInsideAStraightLine(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j], straightLines: PlayerManager.sharedInstance.player1StraightLine) {
                        continue
                    }
                    
                    let option = LearningHelper.shared.isOpenForStraightLine(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j])
                    if option != -1 { // open for straightline
                        return option
                    }
                }
            }
        }
        
        //case 3: check the position for future possible straight line for CPU
        
        if PlayerManager.sharedInstance.player2PebblesOnBoard.count >= 2 {
            for i in 0...PlayerManager.sharedInstance.player2PebblesOnBoard.count-2 {
                for j in i+1...PlayerManager.sharedInstance.player2PebblesOnBoard.count-1 {
                    
                    // skip if both points belongs to a straight line created by Player2
                    if LearningHelper.shared.isInsideAStraightLine(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j], straightLines: PlayerManager.sharedInstance.player2StraightLine) {
                        continue
                    }
                    
                    //mixed pattern
                    let mixedOption = LearningHelper.shared.mixedPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j])
                    if mixedOption != -1 { // open for straightline
                        return mixedOption
                    }
                    let viceVersaMixedOption = LearningHelper.shared.mixedPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[i])
                    if viceVersaMixedOption != -1 { // open for straightline
                        return viceVersaMixedOption
                    }
                    
                    // horizontal vertical pattern 
                    let HVoption = LearningHelper.shared.checkHorizontalVericalPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j])
                    if HVoption != -1 {
                        return HVoption
                    }
                    let viceVersaHVoption = LearningHelper.shared.checkHorizontalVericalPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[i])
                    if viceVersaHVoption != -1 {
                        return viceVersaHVoption
                    }
                    
                    //vertical horizontal pattern
                    let VHoption = LearningHelper.shared.checkVerticalHorizontalPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j])
                    if VHoption != -1 {
                        return VHoption
                    }
                    let viceVersaVHoption = LearningHelper.shared.checkVerticalHorizontalPattern(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[i])
                    if viceVersaVHoption != -1 {
                        return viceVersaVHoption
                    }
                }
            }
        }
        
        //case 4: check the position for future possible straight line for Opposition
        
        if PlayerManager.sharedInstance.player1PebblesOnBoard.count >= 2 {
            for i in 0...PlayerManager.sharedInstance.player1PebblesOnBoard.count-2 {
                for j in i+1...PlayerManager.sharedInstance.player1PebblesOnBoard.count-1 {
                    
                    // skip if both points belongs to a straight line created by Player1
                    if LearningHelper.shared.isInsideAStraightLine(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j], straightLines: PlayerManager.sharedInstance.player1StraightLine) {
                        continue
                    }
                    
                    
                    //mixed pattern
                    let mixedOption = LearningHelper.shared.mixedPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j])
                    if mixedOption != -1 { // open for straightline
                        return mixedOption
                    }
                    let viceVersaMixedOption = LearningHelper.shared.mixedPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[i])
                    if viceVersaMixedOption != -1 { // open for straightline
                        return viceVersaMixedOption
                    }
                    
                    // horizontal vertical pattern
                    let HVoption = LearningHelper.shared.checkHorizontalVericalPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j])
                    if HVoption != -1 {
                        return HVoption
                    }
                    let viceVersaHVoption = LearningHelper.shared.checkHorizontalVericalPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[i])
                    if viceVersaHVoption != -1 {
                        return viceVersaHVoption
                    }
                    
                    //vertical horizontal pattern
                    let VHoption = LearningHelper.shared.checkVerticalHorizontalPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[j])
                    if VHoption != -1 {
                        return VHoption
                    }
                    let viceVersaVHoption = LearningHelper.shared.checkVerticalHorizontalPattern(point1: PlayerManager.sharedInstance.player1PebblesOnBoard[j], point2: PlayerManager.sharedInstance.player1PebblesOnBoard[i])
                    if viceVersaVHoption != -1 {
                        return viceVersaVHoption
                    }
                }
            }
        }
        
        // Generate a random Number and assign still the position not determined
        
        repeat {
            // create a set that pebbles are already placed.
            let placedSet = Set(PlayerManager.sharedInstance.player1PebblesOnBoard).union(Set(PlayerManager.sharedInstance.player2PebblesOnBoard))
            var all = [Int]()
            for i in 1...24 { all.append(i)}
            let diffSet = Set(all).subtracting(placedSet)
            
            if diffSet.count > 0 {
                let random = arc4random() % UInt32(diffSet.count)
                let index = Int(random)
                return Array(diffSet)[index]
            } else {
                break
            }
        } while(true)
        
        return -1
    }
    
    //MARK:- Is it opened for SL to CPU
    
    private func openForStraightLineToCPU() -> Int {
        if PlayerManager.sharedInstance.player2PebblesOnBoard.count >= 2 {
            for i in 0...PlayerManager.sharedInstance.player2PebblesOnBoard.count-2 {
                for j in i+1...PlayerManager.sharedInstance.player2PebblesOnBoard.count-1 {
                    
                    // skip if both points belongs to a straight line created by Player2
                    if LearningHelper.shared.isInsideAStraightLine(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j], straightLines: PlayerManager.sharedInstance.player2StraightLine) {
                        continue
                    }
                    
                    let option = LearningHelper.shared.isOpenForStraightLine(point1: PlayerManager.sharedInstance.player2PebblesOnBoard[i], point2: PlayerManager.sharedInstance.player2PebblesOnBoard[j])
                    if option != -1 { // open for straightline
                        return option
                    }
                }
            }
        }
        return -1
    }
    
    
    //MARK:- Claim Pebbles while playing with iOS
    
    func claimThePebbleWhilePlayingWithiOS() -> Int {
        
        var possibleOptions = Set(PlayerManager.sharedInstance.player1PebblesOnBoard)
        // eliminate those elements belongs to a striaght line
        let eliminatedOptions = PlayerManager.sharedInstance.player1StraightLine
        if eliminatedOptions.count > 0 {
            for index in 0...eliminatedOptions.count-1 {
                possibleOptions.subtract(Set(eliminatedOptions[index]))
            }
        }
        // filter on possibleOptions which will be best for CPU 
        let option = LearningHelper.shared.chooseBestOptionsBeforeSingleMovement(claimingPebbles: Array(possibleOptions), player2Pebbles: PlayerManager.sharedInstance.player2PebblesOnBoard)
        if option != -1 {
            return option
        }
        
        // generate a random number if not decided by the above approach 
        
        repeat {
            let index1 = arc4random() % UInt32(PlayerManager.sharedInstance.player1PebblesOnBoard.count)
            let index = Int(index1)
            let random = PlayerManager.sharedInstance.player1PebblesOnBoard[index]
            
            if PlayerManager.sharedInstance.deadLock(currentPlayer: .player2) {
                return random
            }
            else if random > 0 && random <= 24 && !isElementPresentInAnExistingStraightLine(element: random) {
                return random
            }
        } while(true)
    }
    
    private func isElementPresentInAnExistingStraightLine(element : Int) -> Bool {
        var elementPresentInStraightLine = [Int]()
        if PlayerManager.sharedInstance.player1StraightLine.count > 0 {
            for i in 0...PlayerManager.sharedInstance.player1StraightLine.count-1 {
                elementPresentInStraightLine = PlayerManager.sharedInstance.player1StraightLine[i].filter({ element == $0 })
                if elementPresentInStraightLine.count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
}
