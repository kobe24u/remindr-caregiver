//
//  EmergencyContact.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 18/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class EmergencyContact: NSObject {
    
    var name: String?
    var mobile: String?
    
    override init() {
        
    }
    
    init (name: String, mobile: String) {
        self.name = name
        self.mobile = mobile
    }

}
