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
        let targetViewController = TargetViewController(nibName: "TargetViewController", bundle: NSBundle.mainBundle())
        self.view.addSubview(targetViewController!.view)

        targetViewController!.view.snp_makeConstraints { (make) -> Void in
            let upperView: NSView!
            
            if self.targetViews!.count > 0
            {
                upperView = self.targetViews!.lastObject as! NSView!
            }
            else
            {
                upperView = self.addButton
            }
            
            make.centerY.equalTo(upperView.snp_centerY).offset(40.0)
            make.centerX.equalTo(upperView.snp_centerX)
            make.width.equalTo(450)
            make.height.equalTo(150)
        }
        
        self.targetViews?.addObject(targetViewController!.view)
        self.addButton.enabled = self.shouldAddTarget()
    }
}
