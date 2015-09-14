//
//  Subject.swift
//  10k
//
//  Created by Umut Bozkurt on 14/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift

class Subject: Object
{
    dynamic var name = ""
    let applications = List<Application>()
    
    var records: Array<Record> {
        return linkingObjects(Record.self, forProperty: "subject")
    }
}
