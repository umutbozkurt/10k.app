//
//  SubjectAppsViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 06/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa

class SubjectAppsViewController: NSViewController
{
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var applicationsTableView: NSTableView!
    @IBOutlet var currentSubjectLabel: NSTextField!
    @IBOutlet var seperator: NSView!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var previousButton: NSButton!
    
    var applications: Array<String> = []
    var subjects: Array<String> = []
    var subjectApplicationMap = Dictionary<String, Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.applications = Array(Set(self.fetchApplications())).sorted{ $0 < $1 }  // Aplhabetically order unique objects
        
        self.applicationsTableView.intercellSpacing = CGSizeZero
        self.applicationsTableView.setDelegate(self)
        self.applicationsTableView.setDataSource(self)

        self.currentSubjectLabel.stringValue = self.subjects.first!
        
        self.seperator.wantsLayer = true
        self.seperator.layer?.backgroundColor = NSColor.labelColor().CGColor
        
        self.changeNextButton(0)
        self.previousButton.enabled = self.shouldPromptPreviousSubject()
    }
    
    func fetchApplications() -> Array<String>
    {
        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        let applicationsURL = NSURL(fileURLWithPath: paths.first as! String)
        let dirEnumerator = fileManager.enumeratorAtURL(applicationsURL!, includingPropertiesForKeys: [NSURLNameKey], options:NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: nil)!
        
        return dirEnumerator.allObjects.map({(appURL) -> String in
            var fileName: AnyObject?
            var error: NSError?
            appURL.getResourceValue(&fileName, forKey: NSURLNameKey, error: &error)
            return fileName as! String
        }).filter({(fileName) -> Bool in
            return fileName.pathExtension == "app"
        }).map({(appName: String) -> String in
            return appName.stringByDeletingPathExtension
        })
    }
    
    func shouldPromptNextSubject() -> Bool
    {
        return self.applicationsTableView.selectedRowIndexes.count > 0
    }
    
    func shouldPromptPreviousSubject() -> Bool
    {
        return (self.subjects as NSArray).indexOfObject(self.currentSubjectLabel.stringValue) > 0
    }
    
    @IBAction func promptNextSubject(sender: NSButton)
    {
        let currentIndex = (self.subjects as NSArray).indexOfObject(self.currentSubjectLabel.stringValue)
        self.currentSubjectLabel.stringValue = self.subjects[currentIndex + 1]
        self.changeNextButton(currentIndex + 1)
        
        self.applicationsTableView.deselectAll(nil)
    }
    
    @IBAction func promptPreviousSubject(sender: NSButton)
    {
        self.nextButton.title = "Next"
        self.nextButton.action = Selector("promptNextSubject:")
        
        let currentIndex = (self.subjects as NSArray).indexOfObject(self.currentSubjectLabel.stringValue)
        self.currentSubjectLabel.stringValue = self.subjects[currentIndex - 1]
        self.previousButton.enabled = self.shouldPromptPreviousSubject()
    }
    
    func changeNextButton(forIndex: Int)
    {
        if forIndex == self.subjects.count - 1
        {
            self.nextButton.title =  "Done"
            self.nextButton.action = Selector("submit:")
        }
        
        self.nextButton.enabled = self.shouldPromptNextSubject()
    }
    
    func submit(sender: NSButton)
    {
        println(self.subjectApplicationMap)
    }
}

// MARK: Table View Delegate & Datasource Extension

extension SubjectAppsViewController: NSTableViewDelegate, NSTableViewDataSource
{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return self.applications.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var loadedViews: NSArray?
        NSBundle.mainBundle().loadNibNamed("ApplicationTableViewCell", owner: nil, topLevelObjects: &loadedViews)
        // our view may not be firstItem of loadedViews
        
        var appCell: ApplicationTableViewCell!
        for obj: AnyObject in loadedViews!
        {
            if obj.isKindOfClass(ApplicationTableViewCell)
            {
                appCell = obj as! ApplicationTableViewCell
            }
        }
        
        appCell.setApplication(self.applications[row])
        return appCell
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 30
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        var selectedApplications: Array<String> = []
        self.applicationsTableView.selectedRowIndexes.enumerateIndexesUsingBlock({(index, stop) -> Void in
            selectedApplications.append(self.applications[index])
        })
        self.subjectApplicationMap[self.currentSubjectLabel.stringValue] = selectedApplications
        
        self.nextButton.enabled = self.shouldPromptNextSubject()
    }
}
