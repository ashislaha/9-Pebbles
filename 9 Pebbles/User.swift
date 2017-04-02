//
//  User.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 24/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import Foundation

struct User {
    var name : String!
    var emailId : String!
    var userId : String!
    
    init(name : String, emailId : String, userId : String) {
        self.name = name
        self.emailId = emailId
        self.userId = userId
    }
}
