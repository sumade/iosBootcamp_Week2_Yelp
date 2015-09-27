//
//  DropDownTableViewCell.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/27/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class DropDownFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    @IBOutlet weak var outerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.borderColor = MyColors.CalGold.CGColor
        outerView.layer.borderWidth = 0.75
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
