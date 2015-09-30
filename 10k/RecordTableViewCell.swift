//
//  RecordTableViewCell.swift
//  10k
//
//  Created by Umut Bozkurt on 29/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa

class RecordTableViewCell: NSTableCellView
{
    private let colors = [
        NSColor(red: 41, green: 128, blue: 185, alpha: 1),
        NSColor(red: 241, green: 196, blue: 15, alpha: 1),
        NSColor(red: 46, green: 204, blue: 113, alpha: 1)
    ]
    
    override func drawRect(dirtyRect: NSRect)
    {
        super.drawRect(dirtyRect)
    }

    @IBOutlet var subjectLabel: NSTextField!
    @IBOutlet var progressLabel: NSTextField!
    
    func setSubject(subject: Subject, forIndex: Int)
    {
        self.subjectLabel.stringValue = subject.name
        let totalHours = subject.records.reduce(0, combine: {(total, record) in
            return total + record.endedAt.timeIntervalSinceDate(record.startedAt)
        }) / 3600
        
        if (totalHours > 1000)
        {
            self.progressLabel.stringValue = String(format: "%0.1fk hours", totalHours / 1000)
        }
        else
        {
            self.progressLabel.stringValue = String(format: "%0.1f hours", totalHours)
        }
        
//        let percentageCompleted = (totalHours / 10000)
//        
//        let progressView = NSView(frame: NSRect(x: 0, y: 0, width: CGFloat(percentageCompleted) * self.bounds.width, height: self.bounds.height))
//        progressView.wantsLayer = true
//        progressView.layer?.backgroundColor = self.colors[forIndex].CGColor
        
//        self.addSubview(progressView)
    }
}
