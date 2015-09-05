//
//  TargetViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 05/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa

class TargetViewController: NSViewController
{
    
    @IBOutlet var targetSubjectTextField: NSTextField!
    @IBOutlet var deleteTargetButton: NSButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func asd(sender: AnyObject)
    {
        println("asddad")
    }
    
    func removeTarget(sender: AnyObject?)
    {
        println("asd")
    }
}
