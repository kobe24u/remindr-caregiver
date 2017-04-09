//
//  PhotoCellCollectionViewCell.swift
//  ReMindr
//
//  Created by Vincent Liu on 7/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class PhotoCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: Photo? {
        didSet {

            self.updateUI()
            
        }
    }
    
    private func updateUI()
    {
        if let photo = photo {
            photoImageView.image = photo.featuredImage
        }
    }
}
