//
//  LearningAlgorithmWhenSingleMoveStart.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 04/06/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation

class LearningAlgorithmWhenSingleMoveStart {

    
    /* 
     So when Single move starts : we have to consider few facts 
     
     Input - Player2 (CPU) pebbles on board & Player1 pebbles on board
     
     case 1 : If any Straight line is in open state then close it ( player 2 ) if possible
     case 2 : If any straight line is in open state then block it  ( player 1) if possible
     case 3 : if LINE not in OpenState for player1, then open your Line for claiming from opponent.
     case 4 : Move your pebble having better fitness value
     
     */
    
    static let sharedInstance: LearningAlgorithmWhenSingleMoveStart = { LearningAlgorithmWhenSingleMoveStart() }()
    
    func determinePosition() -> (Int,Int) {
        
        // first list down the possible options i.e. possible Neighbors of player2 OnBoard
        var options = [Int]()
        var dictionary = [Int : [Int]]() // [ "fromPoint" : [to Points having Single Move possible] ]
        
        if PlayerManager.sharedInstance.player2PebblesOnBoard.count > 0 {
            for point in PlayerManager.sharedInstance.player2PebblesOnBoard {
                // check each neighbor and whether it is empty or not
                let neighbor = [ PlayerManager.sharedInstance.neighborPoint(point, neighbor: .left),
                                 PlayerManager.sharedInstance.neighborPoint(point, neighbor: .right),
                                 PlayerManager.sharedInstance.neighborPoint(point, neighbor: .top),
                                 PlayerManager.sharedInstance.neighborPoint(point, neighbor: .down)
                ]
                let tempArr = neighbor.filter({ $0 != -1 })
                
                // if tempArr is not occupied then assign it to options array 
                if tempArr.count > 0 {
                    let emptyPlaces = tempArr.filter({ !PlayerManager.sharedInstance.player1PebblesOnBoard.contains($0) &&  !PlayerManager.sharedInstance.player2PebblesOnBoard.contains($0) })
                    if emptyPlaces.count > 0 {
                        options.append(contentsOf: emptyPlaces)
                        dictionary[point] = emptyPlaces
                    }
                }
            }
        }
        
        //case 1 : check any SL is in opening mode or not for CPU, if there then move
        //case 2 : check any SL is in opening mode or not for opponent
        //case 3 : open your SL if possible check the blocking criteria by Player1
        //case 4 : If any SL is in open mode for opponent, you can able to block it then block it.
        //case 5 : try to bound the Straight Line of opponent so that opponent will not able to open the SL.
        //case 6 : calculate the filtness value which has high probability to create a SL
        
        // case 1 :
        
        let openForSL = openForStraightLine(array: PlayerManager.sharedInstance.player2PebblesOnBoard, straightLines: PlayerManager.sharedInstance.player2StraightLine)
        if openForSL.count > 0 { // cross check with options
            let intersect = Set(options).intersection(Set(openForSL))
            if intersect.count > 0 {
                for item in intersect {
                    let tuples = whichMoveWillCreateAStraightLine(item: item, dictionary: dictionary)
                    if tuples.fromItem != 0 && tuples.toItem != 0 {
                        return tuples
                    }
                }
            }
        }
        
        // case 2 : check any SL is in opening mode or not for opponent
        
        let openForSLToOpponent = openForStraightLine(array: PlayerManager.sharedInstance.player1PebblesOnBoard, straightLines: PlayerManager.sharedInstance.player1StraightLine)
        if openForSLToOpponent.count > 0 { // check the possibilty to block the position 
            let intersect = Set(options).intersection(Set(openForSLToOpponent))
            if intersect.count > 0 {
                if let item = intersect.first {
                    let tuples = whichMoveWillCreateAStraightLine(item: item, dictionary: dictionary)
                    if tuples.fromItem != 0 && tuples.toItem != 0 {
                        return tuples
                    }
                }
            }
        }
        
        // case 3: open your SL if possible, check the blocking criteria by Player1
        // check the keys of the dictionary and intersect with "StraightLine", if match then see the possible move of Player, if not intersect then move it else don't do.
        
        for (key,value) in dictionary {
            for item in PlayerManager.sharedInstance.player2StraightLine {
                let pointInSL = item.filter({ $0 == key })
                if pointInSL.count > 0 {
                    
                    // check whether pointInSL is not blocked by Player1
                    // calculate the neighbor of pointInSL and intersect with Player1PebblesOnBoard, if present then ignore else return it.
                    var neighbor = [Int]()
                    for pebble in pointInSL {
                        neighbor.append(PlayerManager.sharedInstance.neighborPoint(pebble, neighbor: .left))
                        neighbor.append(PlayerManager.sharedInstance.neighborPoint(pebble, neighbor: .right))
                        neighbor.append(PlayerManager.sharedInstance.neighborPoint(pebble, neighbor: .top))
                        neighbor.append(PlayerManager.sharedInstance.neighborPoint(pebble, neighbor: .down))
                    }
                    
                    let intersect = Set(neighbor).intersection(Set(PlayerManager.sharedInstance.player1PebblesOnBoard))
                    if intersect.count == 0 { // return the item
                        if let firstItem = value.first {
                            return (key,firstItem)
                        }
                    }
                }
            }
        }
        
        //case 4 : If any SL is in open mode for opponent, you can able to block it then block it.
        // Find out the possitions that Opposition has an option to create a SL.
        
        let openForSLForOpponent = openForStraightLine(array: PlayerManager.sharedInstance.player1PebblesOnBoard, straightLines: PlayerManager.sharedInstance.player1StraightLine)
        if openForSLForOpponent.count > 0 { // cross check with options
            let intersect = Set(options).intersection(Set(openForSLForOpponent))
            if intersect.count > 0 {
                if let firstItem = intersect.first {
                    for (key,value) in dictionary {
                        if value.contains(firstItem) {
                              return (key,firstItem)
                        }
                    }
                }
            }
        }
        
        // case 5 : try to bound the Straight Line of opponent so that opponent will not able to open the SL.
        // find the neighbor of Player2 SL and intersect with options and choose one
        
        var neighborOfOpponentSL = [Int]()
        for sl in PlayerManager.sharedInstance.player1StraightLine {
            for eachPoint in sl {
                neighborOfOpponentSL.append(PlayerManager.sharedInstance.neighborPoint(eachPoint, neighbor: .left))
                neighborOfOpponentSL.append(PlayerManager.sharedInstance.neighborPoint(eachPoint, neighbor: .right))
                neighborOfOpponentSL.append(PlayerManager.sharedInstance.neighborPoint(eachPoint, neighbor: .top))
                neighborOfOpponentSL.append(PlayerManager.sharedInstance.neighborPoint(eachPoint, neighbor: .down))
            }
        }
        
        if neighborOfOpponentSL.count > 0 {
            neighborOfOpponentSL = neighborOfOpponentSL.filter({ $0 != -1 })
            // intersect with options
            let intersect = Set(neighborOfOpponentSL).intersection(Set(options))
            if intersect.count > 0 {
                if let firstItem = intersect.first {
                    for (key,value) in dictionary {
                        if value.contains(firstItem) {
                            return (key,firstItem)
                        }
                    }
                }
            }
        }
        
        
        
        // Generate a random Number and assign still the position not determined
        
        repeat {
            
            var i = 0
            if options.count > 1 {
                 let index = arc4random() % UInt32(options.count-1)
                 i = Int(index)
            }
            let item = options[i]
            let tuples = checkItem(item: item, dictionary: dictionary)
            if tuples.fromItem != 0 && tuples.toItem != 0 {
                return tuples
            }
        } while(true)
    }
    
    private func checkItem(item : Int, dictionary : [Int : [Int]]) -> (fromItem : Int, toItem : Int) {
        if item > 0 && item <= 24 && !PlayerManager.sharedInstance.player1PebblesOnBoard.contains(item) && !PlayerManager.sharedInstance.player2PebblesOnBoard.contains(item) {
            for (key,value) in dictionary {
                if value.contains(item) {
                    return (key,item)
                }
            }
        }
        return (0,0)
    }
    
    
    private func whichMoveWillCreateAStraightLine(item : Int, dictionary : [Int:[Int]]) -> (fromItem : Int, toItem : Int) {
        // which have the option "item" for single move
        var options = [Int]()
        for (key,value) in dictionary {
            if value.contains(item) {
               options.append(key)
            }
        }
        
        // check the values of options array which will create a SL which contains item. So <options element + item> will create a SL then return the other item.
        
        if options.count == 2 { // then it is an corner case (junction of Horizontal-Vertical )
            
            var temp = PlayerManager.sharedInstance.player2PebblesOnBoard
            
            for option in options { // remove option from Player2PebblesOnBoard and add item to Player2PebblesOnBoard and see any SL is created or not
                if let index = temp.index(of: option) {
                    temp.remove(at: index)
                    temp.append(item)
                    
                    // check any new SL or not , if yes then return (option, item)
                    var diff = Set(temp)
                    for sl in PlayerManager.sharedInstance.player2StraightLine {
                       diff = diff.subtracting(Set(sl))
                    }
                    
                    // check any SL is present or not in "diff" set 
                    let intersect1 = diff.intersection(Set(HorizontalStraightLines.H1))
                    if intersect1.count > 0 { return (option,item) }
                    
                    let intersect2 = diff.intersection(Set(HorizontalStraightLines.H2))
                    if intersect2.count > 0 { return (option,item) }
                    
                    let intersect3 = diff.intersection(Set(HorizontalStraightLines.H3))
                    if intersect3.count > 0 { return (option,item) }
                    
                    let intersect4 = diff.intersection(Set(HorizontalStraightLines.H4))
                    if intersect4.count > 0 { return (option,item) }
                    
                    let intersect5 = diff.intersection(Set(HorizontalStraightLines.H5))
                    if intersect5.count > 0 { return (option,item) }
                    
                    let intersect6 = diff.intersection(Set(HorizontalStraightLines.H6))
                    if intersect6.count > 0 { return (option,item) }
                    
                    let intersect7 = diff.intersection(Set(HorizontalStraightLines.H7))
                    if intersect7.count > 0 { return (option,item) }
                    
                    let intersect8 = diff.intersection(Set(HorizontalStraightLines.H8))
                    if intersect8.count > 0 { return (option,item) }
                    
                    let intersect9 = diff.intersection(Set(VerticalStraightLines.V1))
                    if intersect9.count > 0 { return (option,item) }
                    
                    let intersect10 = diff.intersection(Set(VerticalStraightLines.V2))
                    if intersect10.count > 0 { return (option,item) }
                    
                    let intersect11 = diff.intersection(Set(VerticalStraightLines.V3))
                    if intersect11.count > 0 { return (option,item) }
                    
                    let intersect12 = diff.intersection(Set(VerticalStraightLines.V4))
                    if intersect12.count > 0 { return (option,item) }
                    
                    let intersect13 = diff.intersection(Set(VerticalStraightLines.V5))
                    if intersect13.count > 0 { return (option,item) }
                    
                    let intersect14 = diff.intersection(Set(VerticalStraightLines.V6))
                    if intersect14.count > 0 { return (option,item) }
                    
                    let intersect15 = diff.intersection(Set(VerticalStraightLines.V7))
                    if intersect15.count > 0 { return (option,item) }
                    
                    let intersect16 = diff.intersection(Set(VerticalStraightLines.V8))
                    if intersect16.count > 0 { return (option,item) }
                }
            }
        
        } else if options.count > 2 {
            // [options[i], options[j], item] create a SL either H or V. Return the other element except i and j in options array
            for i in 0...options.count-2{
                for j in i+1...options.count-1 {
                    
                    let set = Set([options[i],options[j],item])
                    
                    if set == Set(HorizontalStraightLines.H1) || set == Set(HorizontalStraightLines.H2) || set == Set(HorizontalStraightLines.H3) ||
                        set == Set(HorizontalStraightLines.H4) || set == Set(HorizontalStraightLines.H5) || set == Set(HorizontalStraightLines.H6) ||
                        set == Set(HorizontalStraightLines.H7) || set == Set(HorizontalStraightLines.H8) || set == Set(VerticalStraightLines.V1) ||
                        set == Set(VerticalStraightLines.V2) ||  set == Set(VerticalStraightLines.V3) || set == Set(VerticalStraightLines.V4) ||
                        set == Set(VerticalStraightLines.V5) || set == Set(VerticalStraightLines.V6) || set == Set(VerticalStraightLines.V7) ||
                        set == Set(VerticalStraightLines.V8) {
                        let fromValue = returnTheOption(superSet: options, subSet: [options[i],options[j]])
                        if fromValue != 0 { return (fromValue,item) }
                    }
                }
            }
        }
        
        return (0,0)
    }
    
    private func returnTheOption(superSet : [Int], subSet : [Int]) -> Int {
        let diff = Set(superSet).subtracting(Set(subSet))
        if diff.count > 0 {
            if let firstItem = diff.first {
                return firstItem
            }
        }
        return 0
    }
    
    
    private func openForStraightLine(array : [Int], straightLines : [[Int]]) -> [Int] {
        var options = [Int]()
        if array.count >= 2 {
            for i in 0...array.count-2 {
                for j in i+1...array.count-1 {
                    // skip if both points belongs to a straight line created by Player2
                    if LearningHelper.shared.isInsideAStraightLine(point1: array[i], point2:array[j], straightLines:straightLines) {
                        continue
                    }
                    
                    let option = LearningHelper.shared.isOpenForStraightLine(point1: array[i], point2:array[j])
                    if option != -1 { // open for straightline
                        options.append(option)
                    }
                }
            }
        }
        return options
    }

}
