//
//  FavouriteCell.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class FavouriteCell: UITableViewCell {


    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
