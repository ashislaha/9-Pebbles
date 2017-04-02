//
//  cell1.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 22/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit

struct ButtonPropertyConstats {
    static var DivisionConstant : CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if DeviceType.IS_IPHONE_5 {
                return 100.0 // do not put any corner radius 
            } else {
                return 4.0
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
             return 2.0
        }
        return 4.0
    }
}

class Cell1: UITableViewCell {

    @IBOutlet weak var button1: PebbleButton! { didSet{ button1.layer.cornerRadius = button1.frame.width / ButtonPropertyConstats.DivisionConstant
                                                        button1.backgroundColor = ColorConstants.defaultColor
                                                }}
    @IBOutlet weak var button2: PebbleButton! { didSet{ button2.layer.cornerRadius = button2.frame.width / ButtonPropertyConstats.DivisionConstant
                                                button2.backgroundColor = ColorConstants.defaultColor
                                                }}
    @IBOutlet weak var button3: PebbleButton! { didSet{ button3.layer.cornerRadius = button3.frame.width / ButtonPropertyConstats.DivisionConstant
                                                button3.backgroundColor = ColorConstants.defaultColor
                                                }}
    
    //Action
    
    @IBAction func button1Tapped(_ sender: PebbleButton) {
         print("button1Tapped")
         PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button2Tapped(_ sender: PebbleButton) {
        print("button2Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button3Tapped(_ sender: PebbleButton) {
        print("button3Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
             StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 1, toButton: 3)
             StoredPoints.drawVerticalLines(cellIndex: 1, startButtontag: 1)
        }
    }
    
}

class Cell2: UITableViewCell {
    
    @IBOutlet weak var button4: PebbleButton! { didSet{ button4.layer.cornerRadius = button4.frame.width / ButtonPropertyConstats.DivisionConstant
                                                        button4.backgroundColor = ColorConstants.defaultColor
                                                }}
    @IBOutlet weak var button5: PebbleButton! { didSet{ button5.layer.cornerRadius = button5.frame.width / ButtonPropertyConstats.DivisionConstant
                                                        button5.backgroundColor = ColorConstants.defaultColor
                                                }}
    @IBOutlet weak var button6: PebbleButton! { didSet{ button6.layer.cornerRadius = button6.frame.width / ButtonPropertyConstats.DivisionConstant
                                                        button6.backgroundColor = ColorConstants.defaultColor}}
    
    //Action
    
    @IBAction func button4Tapped(_ sender: PebbleButton) {
        print("button4Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button5Tapped(_ sender: PebbleButton) {
        print("button5Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button6Tapped(_ sender: PebbleButton) {
        print("button6Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 4, toButton: 6)
            StoredPoints.drawVerticalLines(cellIndex: 2, startButtontag: 4)
        }
    }
}


class Cell3: UITableViewCell {
    
    @IBOutlet weak var button7: PebbleButton! { didSet{ button7.layer.cornerRadius = button7.frame.width / ButtonPropertyConstats.DivisionConstant
                                                 button7.backgroundColor = ColorConstants.defaultColor
                                             }}
    @IBOutlet weak var button8: PebbleButton! { didSet{ button8.layer.cornerRadius = button8.frame.width / ButtonPropertyConstats.DivisionConstant
                                                button8.backgroundColor = ColorConstants.defaultColor}}
    @IBOutlet weak var button9: PebbleButton! { didSet{ button9.layer.cornerRadius = button9.frame.width / ButtonPropertyConstats.DivisionConstant
                                                button9.backgroundColor = ColorConstants.defaultColor}}
    
    //Action
    
    @IBAction func button7Tapped(_ sender: PebbleButton) {
        print("button7Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button8Tapped(_ sender: PebbleButton) {
        print("button8Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button9Tapped(_ sender: PebbleButton) {
        print("button9Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 7, toButton: 9)
            StoredPoints.drawVerticalLines(cellIndex: 3, startButtontag: 7)
        }
    }
}
class Cell4: UITableViewCell {
    
    @IBOutlet weak var button10: PebbleButton! { didSet{ button10.layer.cornerRadius = button10.frame.width / ButtonPropertyConstats.DivisionConstant
                                                    button10.backgroundColor = ColorConstants.defaultColor }}
    @IBOutlet weak var button11: PebbleButton! { didSet{ button11.layer.cornerRadius = button11.frame.width / ButtonPropertyConstats.DivisionConstant
        button11.backgroundColor = ColorConstants.defaultColor}}
    @IBOutlet weak var button12: PebbleButton! { didSet{ button12.layer.cornerRadius = button12.frame.width / ButtonPropertyConstats.DivisionConstant
        button12.backgroundColor = ColorConstants.defaultColor}}
    
    @IBOutlet weak var button13: PebbleButton! { didSet{ button13.layer.cornerRadius = button13.frame.width / ButtonPropertyConstats.DivisionConstant
         button13.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button14: PebbleButton! { didSet{ button14.layer.cornerRadius = button14.frame.width / ButtonPropertyConstats.DivisionConstant
        button14.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button15: PebbleButton! { didSet{ button15.layer.cornerRadius = button15.frame.width / ButtonPropertyConstats.DivisionConstant
        button15.backgroundColor = ColorConstants.defaultColor
        }}
    
     //Action
    
    @IBAction func button10Tapped(_ sender: PebbleButton) {
        print("button10Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button11Tapped(_ sender: PebbleButton) {
        print("button11Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    
    @IBAction func button12Tapped(_ sender: PebbleButton) {
        print("button12Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button13Tapped(_ sender: PebbleButton) {
        print("button13Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    
    @IBAction func button14Tapped(_ sender: PebbleButton) {
        print("button14Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button15Tapped(_ sender: PebbleButton) {
        print("button15Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 10, toButton: 12)
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 13, toButton: 15)
            StoredPoints.drawVerticalLines(cellIndex: 4, startButtontag: 10)
        }
    }
    
}
class Cell5: UITableViewCell {
    
    @IBOutlet weak var button16: PebbleButton! { didSet{ button16.layer.cornerRadius = button16.frame.width / ButtonPropertyConstats.DivisionConstant
         button16.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button17: PebbleButton! { didSet{ button17.layer.cornerRadius = button17.frame.width / ButtonPropertyConstats.DivisionConstant
         button17.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button18: PebbleButton! { didSet{ button18.layer.cornerRadius = button18.frame.width / ButtonPropertyConstats.DivisionConstant
         button18.backgroundColor = ColorConstants.defaultColor
        }}
    
    //Action
    @IBAction func button16Tapped(_ sender: PebbleButton) {
        print("button16Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button17Tapped(_ sender: PebbleButton) {
        print("button17Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button18Tapped(_ sender: PebbleButton) {
        print("button18Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 16, toButton: 18)
            StoredPoints.drawVerticalLines(cellIndex: 5, startButtontag: 16)
        }
    }
}
class Cell6: UITableViewCell {
    
    @IBOutlet weak var button19: PebbleButton! { didSet{ button19.layer.cornerRadius = button19.frame.width / ButtonPropertyConstats.DivisionConstant
         button19.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button20: PebbleButton! { didSet{ button20.layer.cornerRadius = button20.frame.width / ButtonPropertyConstats.DivisionConstant
         button20.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button21: PebbleButton! { didSet{ button21.layer.cornerRadius = button21.frame.width / ButtonPropertyConstats.DivisionConstant
         button21.backgroundColor = ColorConstants.defaultColor
        }}
    
    //Action
    
    
    @IBAction func button19Tapped(_ sender: PebbleButton) {
        print("button19Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button20Tapped(_ sender: PebbleButton) {
        print("button20Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    @IBAction func button21Tapped(_ sender: PebbleButton) {
        print("button21Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 19, toButton: 21)
            StoredPoints.drawVerticalLines(cellIndex: 6, startButtontag: 19)
        }
    }
}
class Cell7: UITableViewCell {
    
    
    @IBOutlet weak var button22: PebbleButton! { didSet{ button22.layer.cornerRadius = button22.frame.width / ButtonPropertyConstats.DivisionConstant
         button22.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button23: PebbleButton! { didSet{ button23.layer.cornerRadius = button23.frame.width / ButtonPropertyConstats.DivisionConstant
        button23.backgroundColor = ColorConstants.defaultColor
        }}
    @IBOutlet weak var button24: PebbleButton! { didSet{ button24.layer.cornerRadius = button24.frame.width / ButtonPropertyConstats.DivisionConstant
         button24.backgroundColor = ColorConstants.defaultColor
        }}
    
     //Action
    
    @IBAction func button22Tapped(_ sender: PebbleButton) {
        print("button22Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button23Tapped(_ sender: PebbleButton) {
        print("button23Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    @IBAction func button24Tapped(_ sender: PebbleButton) {
        print("button24Tapped")
        PlayerManager.sharedInstance.colorThePebbleOnButtonTapped(sender,delegate: HelperClass.baseViewInstance)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if StoredPoints.rightMiddleCoordinates.count > 1 && StoredPoints.leftMiddleCoordinates.count > 1 {
            StoredPoints.drawHorizontalLineBetweenButttons(fromButton: 22, toButton: 24)
            StoredPoints.drawVerticalLines(cellIndex: 7, startButtontag: 22)
        }
    }
}


