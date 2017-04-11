//
//  PanicTableViewCell.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 11/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class PanicTableViewCell: UITableViewCell {

    @IBOutlet weak var panicImage: UIImageView!
    
    @IBOutlet weak var panicDate: UILabel!
    
    @IBOutlet weak var panicTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
