//
//  EmergencyService.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 4/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class EmergencyService: NSObject {
    var name: String?
    var type: String?
    var placeID: String?
    var address: String?
    var phone: String?
    var mapsURL: String?
    var lat: Double?
    var lng: Double?
    
    override init() {
        
    }
    
    init(name: String, type: String, address: String, phone: String, mapsURL: String, lat: Double, lng: Double)
    {
        self.name = name
        self.type = type
        self.placeID = nil
        self.address = address
        self.phone = phone
        self.mapsURL = mapsURL
        self.lat = lat
        self.lng = lng
    }
    
    init(name: String, type: String, placeID: String, address: String, phone: String, mapsURL: String, lat: Double, lng: Double)
    {
        self.name = name
        self.type = type
        self.placeID = placeID
        self.address = address
        self.phone = phone
        self.mapsURL = mapsURL
        self.lat = lat
        self.lng = lng
    }

}
