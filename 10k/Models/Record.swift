//
//  Record.swift
//  10k
//
//  Created by Umut Bozkurt on 14/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift

class Record: Object
{
    dynamic var id: String = NSUUID().UUIDString
    dynamic var subject: Subject?
    dynamic var startedAt: NSDate = NSDate()
    dynamic var endedAt: NSDate = NSDate()
    
    override static func primaryKey() -> String?
    {
        return "id"
    }
}
