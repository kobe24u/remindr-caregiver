//
//  Geofence.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import Foundation

class Geofence
{
    var locationName: String?
    var locLat: Double?
    var locLng: Double?
    var radius: Double?
    var enabled: Bool?
    
    init() {
        self.locationName = "nil"
        self.locLat = nil
        self.locLng = nil
        self.radius = 100
        self.enabled = true
        
    }
    
    init(locationName: String, locLat: Double, locLng: Double, radius: Double, enabled: Bool) {
        self.locationName = locationName
        self.locLat = locLat
        self.locLng = locLng
        self.radius = radius
        self.enabled = enabled
    }
}
