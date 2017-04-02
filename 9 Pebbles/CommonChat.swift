//
//  CommonChat.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 23/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation

struct CommonChat {
    var message : String?
    var whoSend : String?
    
    init(message : String, whoSend : String?) {
        self.message = message
        self.whoSend = whoSend
    }
}
