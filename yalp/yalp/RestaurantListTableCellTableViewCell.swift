//
//  RestaurantListTableCellTableViewCell.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class RestaurantListTableCellTableViewCell: UITableViewCell {

    // MARK: UI Elements
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var starsImageView: UIImageView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    // MARK: Model Elements
    var restaurant : Restaurant! {
        didSet {
            thumbImageView.setImageWithURL(NSURL(string: restaurant.imageURL)!)
            thumbImageView.layer.cornerRadius = 10
            thumbImageView.clipsToBounds = true
            thumbImageView.contentMode = .ScaleAspectFit
            restaurantNameLabel.text = restaurant.name
            distanceLabel.text = String(format: "%1.2fmi", restaurant.distanceInMiles)
            starsImageView.setImageWithURL(NSURL(string: restaurant.ratingImgURLSmall)!)
            ratingsLabel.text = String("\(restaurant.reviewCount) Reviews")
            addressLabel.text = restaurant.address.joinWithSeparator(", ")
            categoriesLabel.text = restaurant.categories.joinWithSeparator(", ")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layoutMargins = UIEdgeInsetsZero
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
