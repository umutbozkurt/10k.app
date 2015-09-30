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
    static let cellHeight = 55
    static let buttonHeight = 45
    
    @IBOutlet var recordsTableView: NSTableView!
    
    var subjects = Array<Subject>()
    var activeRecords = Array<Record>()
    var timer: NSTimer?
    let scriptPath = NSBundle.mainBundle().pathForResource("getActiveApplication", ofType: "scpt")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let realm = Realm()
        self.subjects = Array(realm.objects(Subject))
        
        self.view.frame = CGRectMake(
            CGFloat(0),
            CGFloat(0),
            self.view.bounds.width,
            CGFloat(self.subjects.count * TrackerViewController.cellHeight + TrackerViewController.buttonHeight)
        )
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("track"), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear()
    {
        self.subjects = Array(Realm().objects(Subject))
        self.recordsTableView.reloadData()
    }
    
    func track()
    {
        let application = self.getFrontmostApplication()
        
        let subjects = self.subjects.filter { (subject) -> Bool in
            return subject.applications.indexOf("self.name == %@", application) != nil
        }
        
        let realm = Realm()
        realm.write {
            let olderSet = Set(self.activeRecords)
            self.activeRecords = subjects.map({(subject) -> Record in
                var activeRecord = self.activeRecords.filter({(record) -> Bool in
                    return record.subject == subject
                }).first
                
                if (activeRecord == nil)
                {
                    activeRecord = Record()
                    activeRecord!.subject = subject
                    realm.add(activeRecord!, update: false)
                    NSLog("FLUSH DB")
                }
                
                return activeRecord!
            })
            
            let activeSet = Set(self.activeRecords)
            let finishedRecords = olderSet.subtract(activeSet)
            
            for record: Record in finishedRecords
            {
                record.endedAt = NSDate()
                realm.add(record, update: true)
                NSLog("FLUSH DB")
            }
        }
    }
    
    func getFrontmostApplication() -> String
    {
        let scriptURL = NSURL(fileURLWithPath: self.scriptPath!)

        var errorDict: NSDictionary?
        let script = NSAppleScript(contentsOfURL: scriptURL!, error: &errorDict)
        
        let result = script!.executeAndReturnError(&errorDict)?.stringValue
        return result!
    }
}

// MARK: Table View Data Source & Delegate

extension TrackerViewController: NSTableViewDelegate, NSTableViewDataSource
{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return self.subjects.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var loadedViews: NSArray?
        NSBundle.mainBundle().loadNibNamed("RecordTableViewCell", owner: nil, topLevelObjects: &loadedViews)
        // our view may not be firstItem of loadedViews
        
        let recordCell = (loadedViews! as Array).filter({(view) -> Bool in
            return view.isKindOfClass(RecordTableViewCell)
        }).first as! RecordTableViewCell

        recordCell.setSubject(self.subjects[row], forIndex: row)
        
        return recordCell
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return CGFloat(TrackerViewController.cellHeight)
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool
    {
        return false
    }
}
