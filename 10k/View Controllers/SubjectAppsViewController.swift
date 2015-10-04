//
//  SubjectAppsViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 06/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift

class SubjectAppsViewController: NSViewController
{
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var applicationsTableView: NSTableView!
    @IBOutlet var currentSubjectLabel: NSTextField!
    @IBOutlet var seperator: NSView!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var previousButton: NSButton!
    
    var eventMonitor: EventMonitor?
    var applications: Array<(name: String, icon: NSImage)> = []
    var subjects: Array<Subject> = []
    var subjectApplicationMap = Dictionary<Subject, Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.applications = self.fetchApplications()
        
        self.applicationsTableView.intercellSpacing = CGSizeZero
        self.applicationsTableView.setDelegate(self)
        self.applicationsTableView.setDataSource(self)
        
        self.currentSubjectLabel.stringValue = self.subjects.first!.name
        
        self.seperator.wantsLayer = true
        self.seperator.layer?.backgroundColor = NSColor.labelColor().CGColor
        
        self.changeNextButton(0)
        self.selectApplicationsForSubjectIndex(0)
        self.previousButton.enabled = self.shouldPromptPreviousSubject()
    }
    
    func fetchApplications() -> Array<(name: String, icon: NSImage)>
    {
        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        let applicationsURL = NSURL(fileURLWithPath: paths.first as! String)
        let dirEnumerator = fileManager.enumeratorAtURL(applicationsURL!, includingPropertiesForKeys: [NSURLNameKey, NSURLEffectiveIconKey], options:NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: nil)!
        
        return dirEnumerator.allObjects.filter({(url) -> Bool in
            return url.pathExtension == "app"
        }).map({(appURL) -> (name: String, icon: NSImage) in
            var error: NSError?
            var fileName: AnyObject?
            var iconImage: AnyObject?
            
            appURL.getResourceValue(&fileName, forKey: NSURLNameKey, error: &error)
            appURL.getResourceValue(&iconImage, forKey: NSURLEffectiveIconKey, error: &error)
            
            return (name: (fileName as! NSString).stringByDeletingPathExtension, icon: iconImage as! NSImage)
        })
    }
    
    func getCurrentSubjectIndex() -> Int
    {
        return (self.subjects as NSArray).indexOfObjectPassingTest{$0.0.name == self.currentSubjectLabel.stringValue}
    }
    
    func shouldPromptNextSubject() -> Bool
    {
        return self.applicationsTableView.selectedRowIndexes.count > 0
    }
    
    func shouldPromptPreviousSubject() -> Bool
    {
        return (self.subjects as NSArray).indexOfObject(self.currentSubjectLabel.stringValue) > 0
    }
    
    func selectApplicationsForSubjectIndex(index: Int)
    {
        let indexes = NSMutableIndexSet()
        
        for application in self.subjects[index].applications
        {
            let i = (self.applications.map({ (app) -> String in
                return app.name
            }) as NSArray).indexOfObject(application.name)
            indexes.addIndex(i)
        }
        
        self.applicationsTableView.selectRowIndexes(indexes, byExtendingSelection: false)
    }
    
    @IBAction func promptNextSubject(sender: NSButton)
    {
        let currentIndex = self.getCurrentSubjectIndex()
        self.currentSubjectLabel.stringValue = self.subjects[currentIndex + 1].name
        self.changeNextButton(currentIndex + 1)
        
        self.selectApplicationsForSubjectIndex(currentIndex)
    }
    
    @IBAction func promptPreviousSubject(sender: NSButton)
    {
        self.nextButton.title = "Next"
        self.nextButton.action = Selector("promptNextSubject:")
        
        let currentIndex = self.getCurrentSubjectIndex()
        self.currentSubjectLabel.stringValue = self.subjects[currentIndex - 1].name
        self.previousButton.enabled = self.shouldPromptPreviousSubject()
        
        self.selectApplicationsForSubjectIndex(currentIndex)
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
        let realm = Realm()
        
        for (subject, applications) in self.subjectApplicationMap
        {
            realm.write({
                subject.applications.extend(applications.map({(application) -> Application in
                    if let app = realm.objects(Application).filter("name == %@", application).first
                    {
                        return app
                    }
                    else
                    {
                        let app = Application()
                        app.name = application.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        realm.add(app, update: false)
                        return app
                    }
                }).filter({(application) -> Bool in
                    return subject.applications.indexOf(application) == nil
                }))
            })
        }
        
        let trackerVC = TrackerViewController(nibName: "TrackerViewController", bundle: nil)
        
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "init")
        
        // switches view controllers
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.popover.contentViewController = trackerVC
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
        
        let appCell = (loadedViews! as Array).filter({(view) -> Bool in
            return view.isKindOfClass(ApplicationTableViewCell)
        }).first as! ApplicationTableViewCell
        
        appCell.setApplication(self.applications[row].name, icon: self.applications[row].icon)

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
            selectedApplications.append(self.applications[index].name)
        })
        
        let currentSubject = self.subjects[self.getCurrentSubjectIndex()]
        self.subjectApplicationMap[currentSubject] = selectedApplications
        
        self.nextButton.enabled = self.shouldPromptNextSubject()
    }
}
