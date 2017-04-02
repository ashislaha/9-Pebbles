//
//  LearningHelper.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 25/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation

struct VerticalStraightLines {
    static let V1 = [1,10,22]
    static let V2 = [4,11,19]
    static let V3 = [7,12,16]
    static let V4 = [2,5,8]
    static let V5 = [17,20,23]
    static let V6 = [9,13,18]
    static let V7 = [6,14,21]
    static let V8 = [3,15,24]
}

struct HorizontalStraightLines {
    static let H1 = [1,2,3]
    static let H2 = [4,5,6]
    static let H3 = [7,8,9]
    static let H4 = [10,11,12]
    static let H5 = [13,14,15]
    static let H6 = [16,17,18]
    static let H7 = [19,20,21]
    static let H8 = [22,23,24]
}


class LearningHelper {
    
    static let shared : LearningHelper = { LearningHelper() }()
    
    /* 
     Lets define the horizontal straight line and vertical straight line 
 
     Horizontal Straightline Set : { [1,2,3] [4,5,6] [7,8,9] [10,11,12] [13,14,15] [16,17,18] [19,20,21] [22,23,24] }
     Vertical Straightline  Set  : { [1,10,22] [4,11,19] [7,12,16] [2,5,8] [17,20,23] [9,13,18] [6,14,21] [3,15,24] }
    */
    
    /* I will give 2 points whether they belongs to any of the above set. If it is then there is open opportunity to make straight line, 
        It returns the the other one, if not then return -1  as a default
    */
    
    func isOpenForStraightLine(point1 : Int, point2 : Int ) -> Int {
        
        var returnElement = -1
        
        // check for Horizontal
        
        if let element = elementPresent(array:HorizontalStraightLines.H1 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H2 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H3 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H4 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H5 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H6 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H7 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:HorizontalStraightLines.H8 , point1: point1, point2: point2) { returnElement = element }
        
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        // check for vertical
        
        if let element = elementPresent(array:VerticalStraightLines.V1 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V2 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V3, point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V4, point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V5 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V6 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V7 , point1: point1, point2: point2) { returnElement = element }
        else if let element = elementPresent(array:VerticalStraightLines.V8 , point1: point1, point2: point2) { returnElement = element }
        
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        return -1
    }
    
    private func checkReturnElement(returnElement : Int) -> Bool {
        if returnElement != -1 {
            if PlayerManager.sharedInstance.player1PebblesOnBoard.contains(returnElement) || PlayerManager.sharedInstance.player2PebblesOnBoard.contains(returnElement) {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    private func elementPresent(array : [Int], point1 : Int , point2 : Int) -> Int? {
        if array.contains(point1) && array.contains(point2) {
            if let element =  array.filter({ $0 != point1 && $0 != point2 }).last {
                return element
            }
        }
        return nil
    }
    
    
    //MARK:- Check the patterns (which increases the chances to make straight line )
    
    /*
     Horizontal-Vertical pattern : 
     
        |    |    |       |     |   |
        10 - 11 - 12  and 13 - 14 - 15
        |    |    |       |     |   |
     
    Vertical - Horizontal pattern :
     
     - 2 -          - 17 -
     - 5 -   and    - 20 -
     - 8 -          - 23 -
     
     Horizontal - Horizontal pattern :
     
     7  - 8 -  9          4 -   5 -  6          1   - 2 -  3
     12       13  and     11        14   and    10         15
     16 - 17- 18          19 - 20 - 21          22 - 23  - 24
     
     
     If any element belongs to [10,11,12] and another element belongs any of the wings, put your pebbles at the junction, considering others elements
     are empty.
     
     */
    
    //MARK:- Horizontal - Vertical Pattern
    // H4 & H5
    
    func checkHorizontalVericalPattern(point1 : Int, point2 : Int) -> Int {
        
        if isTheOnlyElementPresentInTheLine(linePoints: HorizontalStraightLines.H4, point: point1).0 {
            // check the points is present in the cross-section or not
            let theOtherEmptyPoints = isTheOnlyElementPresentInTheLine(linePoints: HorizontalStraightLines.H4, point: point1).1
            // let point2 is belonging to the other side of theOtherEmptyPoints
            if theOtherEmptyPoints.count > 0 {
                var middlePoint = middlePointOfLine(line: VerticalStraightLines.V1, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line: VerticalStraightLines.V2, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line: VerticalStraightLines.V3, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
            }
        }
        
        if isTheOnlyElementPresentInTheLine(linePoints: HorizontalStraightLines.H5, point: point1).0 {
            // check the points is present in the cross-section or not
            let theOtherEmptyPoints = isTheOnlyElementPresentInTheLine(linePoints: HorizontalStraightLines.H5, point: point1).1
            // let point2 is belonging to the other side of theOtherEmptyPoints
            if theOtherEmptyPoints.count > 0 {
                var middlePoint = middlePointOfLine(line: VerticalStraightLines.V6, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line: VerticalStraightLines.V7, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line: VerticalStraightLines.V8, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
            }
        }
        
        return -1
    }
    
    //MARK:- Vertical - Horizontal Pattern
    // V4 & V5
    
    func checkVerticalHorizontalPattern(point1 : Int, point2 : Int) -> Int {
        
        if isTheOnlyElementPresentInTheLine(linePoints: VerticalStraightLines.V4, point: point1).0 {
            // check the points is present in the cross-section or not
            let theOtherEmptyPoints = isTheOnlyElementPresentInTheLine(linePoints: VerticalStraightLines.V4, point: point1).1
            // let point2 is belonging to the other side of theOtherEmptyPoints
            if theOtherEmptyPoints.count > 0 {
                var middlePoint = middlePointOfLine(line:HorizontalStraightLines.H1, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line:HorizontalStraightLines.H2, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line:HorizontalStraightLines.H3, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
            }
        }
        
        if isTheOnlyElementPresentInTheLine(linePoints: VerticalStraightLines.V5, point: point1).0 {
            // check the points is present in the cross-section or not
            let theOtherEmptyPoints = isTheOnlyElementPresentInTheLine(linePoints: VerticalStraightLines.V5, point: point1).1
            // let point2 is belonging to the other side of theOtherEmptyPoints
            if theOtherEmptyPoints.count > 0 {
                var middlePoint = middlePointOfLine(line:HorizontalStraightLines.H6, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line:HorizontalStraightLines.H7, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
                middlePoint = middlePointOfLine(line:HorizontalStraightLines.H8, point2: point2)
                if middlePoint != -1 {
                    return middlePoint
                }
            }
        }
        
        return -1
    }
    
    private func middlePointOfLine(line : [Int], point2 : Int ) -> Int {
        if point2 == line.first && !PlayerManager.sharedInstance.player1PebblesOnBoard.contains(line.last!) &&
            !PlayerManager.sharedInstance.player2PebblesOnBoard.contains(line.last!) {
            return line[1]
        } else if point2 == line.last && !PlayerManager.sharedInstance.player1PebblesOnBoard.contains(line.first!) &&
            !PlayerManager.sharedInstance.player2PebblesOnBoard.contains(line.first!) {
            return line[1]
        }
        return -1
    }
    
    private func isTheOnlyElementPresentInTheLine( linePoints : [Int] , point : Int) -> (Bool, [Int]) {
        if linePoints.contains(point) {
            // if the others 2 points are empty
            // retrieve other 2 points also and return
            
            let otherPoints = linePoints.filter({ $0 != point })
            let presentArr = otherPoints.filter({
                PlayerManager.sharedInstance.player1PebblesOnBoard.contains($0) || PlayerManager.sharedInstance.player2PebblesOnBoard.contains($0)
            })
            if presentArr.count > 0 {
                return (false, [])
            } else {
                return (true,otherPoints)
            }
        }
        return (false,[])
    }

    
    //MARK:- Mixed Pattern
    /*
     
     Mixed pattern :
     
     7  - 8 -  9          4 -   5 -  6          1   - 2 -  3
     12       13  and     11        14   and    10         15
     16 - 17- 18          19 - 20 - 21          22 - 23  - 24
 
     */
    
    
    func mixedPattern(point1 : Int, point2 : Int) -> Int {
        
        var returnElement = -1
        
        // H1-H8 , H2-H7, H3-H6
        if let matchedElement = horizontalHorizontalPattern(point1: point1, point2: point2, line1: HorizontalStraightLines.H1, line2: HorizontalStraightLines.H8){
            returnElement = matchedElement
        } else if let matchedElement = horizontalHorizontalPattern(point1: point1, point2: point2, line1: HorizontalStraightLines.H2, line2: HorizontalStraightLines.H7){
            returnElement = matchedElement
        } else if let matchedElement = horizontalHorizontalPattern(point1: point1, point2: point2, line1: HorizontalStraightLines.H3, line2: HorizontalStraightLines.H6){
            returnElement = matchedElement
        }
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        // H1 - V1 - H8 - V8
        if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H1, verticalLine: VerticalStraightLines.V1){
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H1, verticalLine: VerticalStraightLines.V8) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H8, verticalLine: VerticalStraightLines.V1) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H8, verticalLine: VerticalStraightLines.V8) {
            returnElement = element
        }
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        // H2 - V2 - H7 - V7
        if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H2, verticalLine: VerticalStraightLines.V2) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H2, verticalLine: VerticalStraightLines.V7) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H7, verticalLine: VerticalStraightLines.V2) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H7, verticalLine: VerticalStraightLines.V7) {
            returnElement = element
        }
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        // H3 - V3 - H6 - V6
        if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H3, verticalLine: VerticalStraightLines.V3) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H3, verticalLine: VerticalStraightLines.V6) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H6, verticalLine: VerticalStraightLines.V3) {
            returnElement = element
        } else if let element = horizontalTwiceVertical(point1: point1, point2: point2, horizontalLine: HorizontalStraightLines.H6, verticalLine: VerticalStraightLines.V6) {
            returnElement = element
        }
        if checkReturnElement(returnElement: returnElement) { return returnElement }
        
        return -1
    }
    
    private func horizontalHorizontalPattern(point1 : Int, point2 : Int, line1 : [Int], line2 : [Int]) -> Int? {
        if point1 == line1.first && (point2 == line2[1] || point2 == line2.last) {
            return line2.first!
        } else if point1 == line1.last && (point2 == line2[1] || point2 == line2.first) {
            return line2.last!
        }
        return nil
    }
    
    // point1 is the middle of the Horizontal line
    private func horizontalTwiceVertical(point1 : Int, point2 : Int, horizontalLine : [Int], verticalLine : [Int]) -> Int? {
        if point1 == horizontalLine[1] && (point2 == verticalLine.last || point2 == verticalLine[1]) {
            return horizontalLine.first
        }
        return nil
    }
    
    //MARK:- Belongs to a straightLine or not
    
    func isInsideAStraightLine(point1 : Int, point2 : Int, straightLines : [[Int]]) -> Bool {
        let set = Set([point1,point2])
        if straightLines.count > 0 {
            for i in 0...straightLines.count-1 {
                if set.isSubset(of: Set(straightLines[i])) {
                    return true
                }
            }
        }
        return false
    }
    
    //MARK:- Claim Pebble before Single movement starts
    
    func chooseBestOptionsBeforeSingleMovement(claimingPebbles : [Int], player2Pebbles : [Int] ) -> Int {
        
        // case 1: if claiming Pebbles belongs to nearer to straight line, remove it 
        if player2Pebbles.count > 0 && PlayerManager.sharedInstance.player2StraightLine.count > 0 {
            for i in 0...PlayerManager.sharedInstance.player2StraightLine.count-1 {
                for j in 0...2 {
                let neighbor = [ PlayerManager.sharedInstance.neighborPoint(PlayerManager.sharedInstance.player2StraightLine[i][j], neighbor: .left),
                                 PlayerManager.sharedInstance.neighborPoint(PlayerManager.sharedInstance.player2StraightLine[i][j], neighbor: .right),
                                 PlayerManager.sharedInstance.neighborPoint(PlayerManager.sharedInstance.player2StraightLine[i][j], neighbor: .top),
                                 PlayerManager.sharedInstance.neighborPoint(PlayerManager.sharedInstance.player2StraightLine[i][j], neighbor: .down)
                               ]
                let intersect = Set(claimingPebbles).intersection(Set(neighbor))
                    if intersect.count > 0 {
                        if let firstElement = intersect.first {
                            return firstElement
                        }
                    }
                }
            }
        }
    
        return -1
    }
}
