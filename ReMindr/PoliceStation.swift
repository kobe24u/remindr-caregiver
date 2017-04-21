//
//  PoliceStation.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 20/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class PoliceStation: NSObject {

    var name: String?
    var placeID: String?
    var address: String?
    var phone: String?
    var rating: Double?
    var imageURL: String?
    var mapsURL: String?
    var website: String?
    var lat: Double?
    var lng: Double?
    var isClosest: Bool?
    
    override init() {
        
    }
    
    init(name: String, placeID: String, rating: Double, imageURL: String, lat: Double, lng: Double, isClosest: Bool)
    {
        self.name = name
        self.placeID = placeID
        self.address = nil
        self.phone = nil
        self.rating = rating
        self.imageURL = imageURL
        self.mapsURL = nil
        self.website = nil
        self.lat = lat
        self.lng = lng
        self.isClosest = isClosest
    }

    
    init(name: String, placeID: String, address: String, phone: String, rating: Double, imageURL: String, mapsURL: String, website: String, lat: Double, lng: Double, isClosest: Bool)
    {
        self.name = name
        self.placeID = placeID
        self.address = address
        self.phone = phone
        self.rating = rating
        self.imageURL = imageURL
        self.mapsURL = mapsURL
        self.website = website
        self.lat = lat
        self.lng = lng
        self.isClosest = isClosest
    }
}

/*
 
 EXAMPLE INFORMATION
 
 "international_phone_number" : "+61 3 9524 9500",
 "name" : "Caulfield Police Station"
 "formatted_address" : "289 Hawthorn Rd, Caulfield VIC 3162, Australia"
 "geometry" : {
    "location" : {
        "lat" : -37.8812381,
        "lng" : 145.0232774
    }
 "place_id" : "ChIJ0R_EbKNp1moRkpTalxsUzCU",
 "rating" : 3.4
 "url" : "https://maps.google.com/?cid=2723573983396664466",
 "website" : "http://www.police.vic.gov.au/content.asp?Document_ID=612"
 */
