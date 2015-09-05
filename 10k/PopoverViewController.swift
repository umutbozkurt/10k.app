//
//  PopoverViewController.swift
//  Outlier
//
//  Created by Umut Bozkurt on 03/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import SnapKit


class PopoverViewController: NSViewController
{
    @IBOutlet var addButton: NSButton!
    var targetViews: Array<TargetView>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.targetViews = Array()
    }
    
    func shouldAddTarget() -> Bool
    {
        return self.targetViews?.count < 3
    }

    @IBAction func addTarget(sender: AnyObject)
    {
        var loadedViews: NSArray?
        NSBundle.mainBundle().loadNibNamed("TargetView", owner: nil, topLevelObjects: &loadedViews)
        // our view may not be firstItem of loadedViews
        
        var targetView: TargetView!
        for obj: AnyObject in loadedViews!
        {
            if obj.isKindOfClass(TargetView)
            {
                targetView = obj as! TargetView
            }
        }
        
        self.view.addSubview(targetView)
        targetView.removeButton.target = self
        targetView.removeButton.action = Selector("removeTargetView:")
        self.targetViews?.append(targetView)
        self.arrangeTargetViews()
        self.addButton.enabled = self.shouldAddTarget()
    }
    
    private func arrangeTargetViews()
    {
        var upperView: NSView = self.addButton
        
        for targetView: TargetView in self.targetViews!.reverse()
        {
            targetView.snp_remakeConstraints { (make) -> Void in
                make.centerY.equalTo(upperView.snp_centerY).offset(40.0)
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
    }
}
