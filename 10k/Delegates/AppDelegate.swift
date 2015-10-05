//
//  AppDelegate.swift
//  10k
//
//  Created by Umut Bozkurt on 03/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        if let button = self.statusItem.button
        {
            button.image = NSImage(named: "10k")
            button.action = Selector("togglePopover:")
        }
        
        self.eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask | NSEventMask.RightMouseDownMask){
            [unowned self] event in
            if self.popover.shown
            {
                self.hidePopover(event)
            }
        }
        
        // Run automatically at startup
        let isStartupSet = NSUserDefaults.standardUserDefaults().boolForKey("isStartupSet")
        if (!isStartupSet)
        {
            if (!LaunchStarter.applicationIsInStartUpItems())
            {
                LaunchStarter.toggleLaunchAtStartup()
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isStartupSet")
        }
        
        let config = Realm.Configuration(
            schemaVersion: 1,
            
            migrationBlock: { migration, oldSchemaVersion in
                
        })
        Realm.Configuration.defaultConfiguration = config
        
        Realm().write { () -> Void in
            Realm().deleteAll()
        }
        
        if (Realm().objects(Subject).count == 0)
        {
            self.popover.contentViewController = WelcomeViewController(nibName:"WelcomeViewController", bundle:nil)
        }
        else
        {
            self.popover.contentViewController = TrackerViewController(nibName:"TrackerViewController", bundle:nil)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification)
    {
        
    }
    
    private func showPopover(sender: AnyObject?)
    {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
        }
        
        self.eventMonitor?.start()
    }
    
    private func hidePopover(sender: AnyObject?)
    {
        popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?)
    {
        if self.popover.shown
        {
            self.hidePopover(sender)
        }
        else
        {
            self.showPopover(sender)
        }
    }
}

// MARK: NSUserNotificationCenter Delegate Methods

extension AppDelegate: NSUserNotificationCenterDelegate
{
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification)
    {
        if (notification.activationType == NSUserNotificationActivationType.ActionButtonClicked)
        {
            let subjects = notification.valueForKey("_alternateActionButtonTitles") as! NSArray
            let index = notification.valueForKey("_alternateActionIndex") as! Int
            
            // There will be multiple Records on userInfo, delete irrelevant ones and save current subject's Record
            let realm = Realm()
            
            realm.write{
                let payload = notification.userInfo as! Dictionary<String, Array<String>>
                for recordId in payload["recordIDs"]!
                {
                    let record = realm.objectForPrimaryKey(Record.self, key: recordId)!
                    let relevant = record.subject!.name == (subjects[index] as! String)
                    
                    if (relevant)
                    {
                        record.endedAt = NSDate()
                        realm.add(record, update: true)
                        
                        NSLog("FLUSH DB")
                    }
                    else
                    {
                        realm.delete(record)
                    }
                }
            }
        }
    }
}

