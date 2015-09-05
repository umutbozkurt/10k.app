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
    var targetViews: NSMutableArray?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.targetViews = NSMutableArray()
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
        self.targetViews?.addObject(targetView)
        self.arrangeTargetViews()
        self.addButton.enabled = self.shouldAddTarget()
    }
    
    private func arrangeTargetViews()
    {
        for var i = self.targetViews!.count - 1; i >= 0; i--
        {
            let targetView = self.targetViews!.objectAtIndex(i) as! TargetView
            
            targetView.snp_remakeConstraints { (make) -> Void in
                let upperView: NSView!
                
                if i == 0
                {
                    upperView = self.addButton
                }
                else
                {
                    upperView = self.targetViews!.objectAtIndex(i - 1) as! NSView
                }
                
                make.centerY.equalTo(upperView.snp_centerY).offset(40.0)
                make.centerX.equalTo(upperView.snp_centerX)
                make.width.equalTo(450)
                make.height.equalTo(150)
            }
        }
    }
    
    func removeTargetView(targetView: TargetView)
    {
        self.targetViews?.removeObject(targetView)
        targetView.removeFromSuperview()
        self.arrangeTargetViews()
    }
}
