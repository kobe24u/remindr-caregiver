//
//  Photo.swift
//  ReMindr
//
//  Created by Vincent Liu on 7/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo
{
    var title = ""
    var featuredImage: UIImage
    var audioURL: String?
    
    init(title: String, featuredImage: UIImage,  audioURL: String)
    {
        self.title = title
        self.featuredImage = featuredImage
        self.audioURL = audioURL
    }

}
