//
//  AppDelegate.swift
//  10k
//
//  Created by Umut Bozkurt on 03/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa


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
            button.image = NSImage(named: "cloud")
            button.action = Selector("togglePopover:")
        }
        
        self.eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask | NSEventMask.RightMouseDownMask){
            [unowned self] event in
            if self.popover.shown
            {
                self.hidePopover(event)
            }
        }
        
        self.popover.contentViewController = PopoverViewController(nibName:"PopoverViewController", bundle:nil)
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

