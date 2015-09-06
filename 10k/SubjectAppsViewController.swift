//
//  SubjectAppsViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 06/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa

class SubjectAppsViewController: NSViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        println(self.fetchApplications())
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
        })
    }
    
}
