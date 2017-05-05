//
//  SettingsTableViewCell.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingImage: UIImageView!

    @IBOutlet weak var settingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
