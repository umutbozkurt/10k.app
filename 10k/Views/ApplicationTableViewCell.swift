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
    @IBOutlet var iconCenterXConstraint: NSLayoutConstraint!
    
//    override func awakeFromNib()
//    {
////        println(applicationLabel.backgroundColor?.CGColor)
//    }
    
    func setApplication(name: String, icon: NSImage)
    {
        self.applicationLabel.stringValue = name
        self.icon.image = icon
        
        let labelFitSize = self.applicationLabel.sizeThatFits(NSMakeSize(CGFloat.max, CGFloat.max)).width
        
        self.iconCenterXConstraint.constant = labelFitSize / 2 + self.icon.bounds.size.width / 2
        self.layoutSubtreeIfNeeded()
    }
}
