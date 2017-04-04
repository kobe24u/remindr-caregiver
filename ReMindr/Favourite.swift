//
//  Favourite.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import Foundation

class Favourite: NSObject
{
    var title: String?
    var desc: String?
    var status: String?
    var imageURL: String?
    var lat: String?
    var lng: String?
    
    
    override init()
    {
        self.title = "none"
        self.desc = "none"
        self.status = "Good"
        self.imageURL = nil
        self.lat = nil
        self.lng = nil
    }
    
    init(title: String, desc: String, status: String) {
        self.title = title
        self.desc = desc
        self.status = status
        self.imageURL = nil
        self.lat = nil
        self.lng = nil
    }
    
    init(title: String, desc: String, status: String, imageURL: String) {
        self.title = title
        self.desc = desc
        self.status = status
        self.imageURL = imageURL
        self.lat = nil
        self.lng = nil
    }
    
    init(title: String, desc: String, status: String, lat: String, lng: String) {
        self.title = title
        self.desc = desc
        self.status = status
        self.imageURL = nil
        self.lat = lat
        self.lng = lng
    }
    
    init(title: String, desc: String, status: String, imageURL: String, lat: String, lng: String) {
        self.title = title
        self.desc = desc
        self.status = status
        self.imageURL = imageURL
        self.lat = lat
        self.lng = lng
    }
    
}
