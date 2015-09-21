//
//  TrackerViewController.swift
//  10k
//
//  Created by Umut Bozkurt on 13/09/15.
//  Copyright (c) 2015 Umut Bozkurt. All rights reserved.
//

import Cocoa
import RealmSwift

class TrackerViewController: NSViewController
{
    var subjectApplicationMap = Dictionary<String, Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for (subject, applications) in self.subjectApplicationMap
        {
            let realm = Realm()
            realm.write({
                let sub = Subject()
                sub.name = subject
                sub.applications.extend(applications.map({(application) -> Application in
                    if let app = realm.objects(Application).filter("name == '\(application)'").first
                    {
                        return app
                    }
                    else
                    {
                        let app = Application()
                        app.name = application
                        realm.add(app, update: false)
                        return app
                    }
                }))
                realm.add(sub, update: false)
            })
        }
    }
    
}
