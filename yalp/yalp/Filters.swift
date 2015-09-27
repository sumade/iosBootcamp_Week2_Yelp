//
//  Filters.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import Foundation

class MyColors {
    static let CalGold = UIColor(red:0.99, green:0.71, blue:0.08, alpha:1.0)
    static let CalBlue = UIColor(red:0.00, green:0.20, blue:0.38, alpha:1.0)
}

class Filter {
    enum FilterSections : Int {
        case Deal = 0
        case Distance = 1
        case SortBy = 2
        case Category = 3
    }
    
    static let filterSectionNames : [String] = ["", "Distance", "Sort By", "Category"]

    static let dealLabelText : String = "Offering a Deal"
    
    enum Distance : Int {
        case Auto = 0
        case Point1Mi = 1
        case Point5Mi = 2
        case OneMi = 3
        case TwoMi = 4
        case FiveMi = 5
    }
    
    static let distanceLabelText : [String] = [
        "Auto",
        "0.1 miles",
        "0.5 miles",
        "1.0 miles",
        "2.0 miles",
        "5.0 miles"
    ]
    
    static func distanceToMilesDouble(distance: Distance) -> Double {
        switch(distance) {
        case .Auto: return 0.0
        case .Point1Mi: return 0.1
        case .Point5Mi: return 0.5
        case .OneMi: return 1.0
        case .TwoMi: return 2.0
        case .FiveMi: return 5.0
        }
    }
    
    enum SortBy : Int {
        case BestMatch = 0
        case Distance = 1
        case HighestRated = 2
    }
    
    static let sortByLabelText : [String] = [
        "Best Match",
        "Distance",
        "Highest Rated"
    ]
    
    
    struct FilterSettings : CustomStringConvertible {
        var isOfferingADeal : Bool = false
        var distance : Distance = .Auto
        var sortBy : SortBy = .BestMatch
        var selectedCategories : Set<String> = []
        
        var description : String {
            var s = [String]()
            s.append("offering a deal? \(isOfferingADeal)")
            s.append("distance? \(distanceLabelText[distance.rawValue])")
            s.append("sortyBy? \(sortByLabelText[sortBy.rawValue])")
            s.append("categories? \(selectedCategories)")
            return s.joinWithSeparator(",")
        }
    }
}