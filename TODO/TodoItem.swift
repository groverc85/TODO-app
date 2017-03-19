//
//  TodoItem.swift
//  TODO
//
//  Created by Grover Chen on 3/18/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import Foundation

import RealmSwift

class TodoItem: Object {
    dynamic var detail = ""
    dynamic var status = 0
    dynamic var createdAt = NSDate()
}
