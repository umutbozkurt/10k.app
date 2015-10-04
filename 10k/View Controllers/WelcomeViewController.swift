//
//  WelcomeViewController.swift
//  Outlier
//
//  Created by Umut Bozkurt on 03/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import SnapKit
import RealmSwift


class WelcomeViewController: NSViewController
{
    @IBOutlet var addButton: NSButton!
    @IBOutlet var doneButton: NSButton!
    
    var targetViews: Array<TargetView>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.targetViews = Array()
        self.doneButton.enabled = self.shouldSubmit()
    }
    
    func shouldAddTarget() -> Bool
    {
        return self.targetViews?.count < 3
    }
    
    func shouldSubmit() -> Bool
    {
        let hasTargetViews = self.targetViews?.count > 0
        let targetViewsNotEmpty = self.targetViews!.reduce(true, combine: {(result, view: TargetView) in
            return result && (!view.subjectTextField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
        })
        
        return hasTargetViews && targetViewsNotEmpty
    }

    @IBAction func addTarget(sender: AnyObject)
    {
        var loadedViews: NSArray?
        NSBundle.mainBundle().loadNibNamed("TargetView", owner: nil, topLevelObjects: &loadedViews)
        // our view may not be firstItem of loadedViews

        let targetView = (loadedViews! as Array).filter({(view) -> Bool in
            return view.isKindOfClass(TargetView)
        }).first as! TargetView
        
        self.view.addSubview(targetView)
        targetView.removeButton.target = self
        targetView.removeButton.action = Selector("removeTargetView:")
        targetView.subjectTextField.delegate = self
        self.targetViews?.append(targetView)
        self.arrangeTargetViews()
        self.addButton.enabled = self.shouldAddTarget()
        self.doneButton.enabled = self.shouldSubmit()
    }
    
    private func arrangeTargetViews()
    {
        var upperView: NSView = self.addButton
        
        for targetView: TargetView in self.targetViews!.reverse()
        {
            targetView.snp_remakeConstraints { (make) -> Void in
                make.centerY.equalTo(upperView.snp_centerY).offset(40)
                make.centerX.equalTo(upperView.snp_centerX)
                make.width.equalTo(450)
                make.height.equalTo(150)
                
                upperView = targetView
            }
        }
    }
    
    func removeTargetView(sender: NSButton)
    {
        self.targetViews = self.targetViews?.filter({(view: TargetView) -> Bool in
            let isMatch = view.removeButton != sender
            
            if !isMatch
            {
                view.removeFromSuperview()
            }
            
            return isMatch
        })
        
        self.arrangeTargetViews()
        self.addButton.enabled = self.shouldAddTarget()
        self.doneButton.enabled = self.shouldSubmit()
    }
    @IBAction func submit(sender: NSButton)
    {
        let subjectVC = SubjectAppsViewController(nibName: "SubjectAppsViewController", bundle: nil)
        subjectVC?.subjects = self.targetViews!.map({(view: TargetView) -> Subject in
            
            let realm = Realm()
            var sub = realm.objects(Subject).filter("name == %@", view.subjectTextField.stringValue).first
            
            realm.write({
                if (sub == nil)
                {
                    sub = Subject()
                    sub!.name = view.subjectTextField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    realm.add(sub!, update: false)
                }
                else
                {
                    realm.add(sub!, update: true)
                }
            })
            
            return sub!
        })
        
        // switches view controllers
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.popover.contentViewController = subjectVC
    }
}

// MARK: TextField Delegate

extension WelcomeViewController: NSTextFieldDelegate
{
    override func controlTextDidChange(obj: NSNotification)
    {
        self.doneButton.enabled = self.shouldSubmit()
    }
}
