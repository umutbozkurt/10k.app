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
    @IBOutlet var icon: NSImageView!
    
    func setApplication(name: String, icon: NSImage)
    {
        self.applicationLabel.stringValue = name
        self.icon.image = icon
    }
}
