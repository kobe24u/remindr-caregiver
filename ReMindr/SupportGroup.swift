//
//  SupportGroup.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class SupportGroup: NSObject {

    var name: String?
    var address: String?
    var suburb: String?
    var state: String?
    var postcode: Int?
    var contact: String?
    var email: String?
    var website: String?
    var mapsURL: String?
    var latitude: Double?
    var longitude: Double?
    
    override init() {
        
    }
    
    init(name: String, address: String, suburb: String, state: String, postcode: Int, contact: String, email: String, website: String, mapsURL: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.suburb = suburb
        self.state = state
        self.postcode = postcode
        self.contact = contact
        self.email = email
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
        self.mapsURL = mapsURL
    }
    
}
