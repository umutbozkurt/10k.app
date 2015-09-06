//
//  ApplicationTableViewCell.swift
//  10k
//
//  Created by Umut Bozkurt on 07/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa

class ApplicationTableViewCell: NSTableCellView
{
    @IBOutlet var applicationLabel: NSTextField!
    
    func setApplication(application: String)
    {
        self.applicationLabel.stringValue = application
    }
    
    override func prepareForReuse() {
        println("reuse")
    }
}
