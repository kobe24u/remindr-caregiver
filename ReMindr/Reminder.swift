//
//  Reminder.swift
//  ReMindr
//
//  Created by Vincent Liu on 22/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import Foundation
import UIKit

class Reminder: NSObject {
    // Properties
    var notification: UILocalNotification
    var name: String
    var time: Date
    var completed: String?
    var uuid: String?
    
    // Archive Paths for Persistent Data
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("reminders")
    
    // enum for property types
    struct PropertyKey {
        static let nameKey = "name"
        static let timeKey = "time"
        static let notificationKey = "notification"
    }
    
    // Initializer
    init(name: String, time: Date, notification: UILocalNotification, completed: String, uuid: String) {
        // set properties
        self.name = name
        self.time = time
        self.notification = notification
        self.completed = completed
        self.uuid = uuid
        super.init()
    }
    
    // Destructor
    deinit {
        // cancel notification
        UIApplication.shared.cancelLocalNotification(self.notification)
    }
    
    // NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(time, forKey: PropertyKey.timeKey)
        aCoder.encode(notification, forKey: PropertyKey.notificationKey)
    }
    
//    required convenience init(coder aDecoder: NSCoder) {
//        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
//        
//        // Because photo is an optional property of Meal, use conditional cast.
//        let time = aDecoder.decodeObject(forKey: PropertyKey.timeKey) as! Date
//        
//        let notification = aDecoder.decodeObject(forKey: PropertyKey.notificationKey) as! UILocalNotification
//        
//        // Must call designated initializer.
//        self.init(name: name, time: time, notification: notification)
//    }
}
