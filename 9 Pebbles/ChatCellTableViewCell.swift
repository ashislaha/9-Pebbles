//
//  ChatCellTableViewCell.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 11/12/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit

class ChatCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textLbl: UILabel! {
        didSet {
            //textLbl.layer.cornerRadius = 15
            //textLbl.backgroundColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1)
        }
    }
}
