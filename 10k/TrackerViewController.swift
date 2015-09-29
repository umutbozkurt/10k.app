//
//  TrackerViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 13/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift

class TrackerViewController: NSViewController
{
    var subjects = Array<Subject>()
    var timer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let realm = Realm()
        self.subjects = Array(realm.objects(Subject))
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("track"), userInfo: nil, repeats: true)
    }
    
    func track()
    {
        let application = self.getFrontmostApplication()
        
        let subjects = self.subjects.filter { (subject) -> Bool in
            return subject.applications.indexOf("self.name == %@", application) != nil
        }
        
        NSLog("APPLICATION: %@", application)
        NSLog("SUBJECTS: %@", subjects)
    }
    
    func getFrontmostApplication() -> String
    {
        let scriptPath = NSBundle.mainBundle().pathForResource("getActiveApplication", ofType: "scpt")
        let scriptURL = NSURL(fileURLWithPath: scriptPath!)

        var errorDict: NSDictionary?
        let script = NSAppleScript(contentsOfURL: scriptURL!, error: &errorDict)
        
        let result = script!.executeAndReturnError(&errorDict)?.stringValue
        return result!
    }
}
