//
//  Panic.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 11/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class Panic: NSObject {
    var eventName: String?
    var receivedDate: String?
    var receivedTime: String?
    var receivedLat: String?
    var receivedLng: String?
    var resolvedDate: String?
    var resolvedTime: String?
    var resolved: String?
    
    override init() {
        
    }
    
    init(eventName: String, receivedDate: String, receivedTime: String, receivedLat: String, receivedLng: String, resolved: String)
    {
        self.eventName = eventName
        self.receivedDate = receivedDate
        self.receivedTime = receivedTime
        self.receivedLat = receivedLat
        self.receivedLng = receivedLng
        self.resolvedDate = "nil"
        self.resolvedTime = "nil"
        self.resolved = resolved
    }
}
