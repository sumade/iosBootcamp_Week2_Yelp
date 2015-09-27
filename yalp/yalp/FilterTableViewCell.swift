//
//  FilterTableViewCell.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class MyCustomSwitch : UISwitch {
    var sectionId : Int = 0
    var rowId : Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var switchState: MyCustomSwitch!
    @IBOutlet weak var infoLabel: UILabel!
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
