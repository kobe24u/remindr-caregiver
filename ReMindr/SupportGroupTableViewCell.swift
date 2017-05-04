//
//  SupportGroupTableViewCell.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class SupportGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelContact: UILabel!
    
    @IBOutlet weak var labelIndex: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
