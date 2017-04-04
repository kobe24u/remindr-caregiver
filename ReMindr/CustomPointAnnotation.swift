//
//  CustomPointAnnotation.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 1/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    
    override init()
    {
        self.coordinate = CLLocationCoordinate2DMake(-34, 145)
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, imageName: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
    
}
