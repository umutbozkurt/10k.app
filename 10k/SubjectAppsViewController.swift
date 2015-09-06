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
    @IBOutlet var applicationsTableView: NSTableView!
    var applications: Array<String> = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.applications = self.fetchApplications()
        self.applicationsTableView.intercellSpacing = CGSizeZero
        self.applicationsTableView.setDelegate(self)
        self.applicationsTableView.setDataSource(self)
    }
    
    func fetchApplications() -> Array<String>
    {
        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        let applicationsURL = NSURL(fileURLWithPath: paths.first as! String)
        
        let dirEnumerator = fileManager.enumeratorAtURL(applicationsURL!, includingPropertiesForKeys: [NSURLNameKey], options:NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: nil)!
        
        let applicationURLS = dirEnumerator.allObjects
        
        return applicationURLS.map({(appURL) -> String in
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
}
