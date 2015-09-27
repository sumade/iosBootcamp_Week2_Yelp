//
//  Restaurant.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Restaurant: CustomStringConvertible {
    
    private(set) var rating: Int = 0
    private(set) var reviewCount: Int = 0
    private(set) var phone: String = ""
    private(set) var categories: [String] = []
    private(set) var snippetImageURL: String = ""
    private(set) var id: String = ""
    private(set) var ratingImgURL: String = ""
    private(set) var imageURL: String = ""
    private(set) var isClaimed: Bool = false
    private(set) var mobileURL: String = ""
    private(set) var ratingImgURLSmall: String = ""
    private(set) var yelpURL: String = ""
    private(set) var displayPhone: String = ""
    private(set) var ratingImgURLLarge: String = ""
    private(set) var isClosed: Bool = false
    private(set) var snippetText: String = ""
    private(set) var distanceInMiles: Double = 0.0
    private(set) var name: String = ""
    private(set) var address: [String] = []
    
    init(dict: Dictionary<String,JSON>){
        if let rating = dict["rating"]?.int {
            self.rating = rating
        }
        
        if let reviewCount = dict["review_count"]?.int {
            self.reviewCount = reviewCount
        }
        
        if let cats = dict["categories"]?.arrayValue {
            self.categories = cats.map{ $0[0].string! }
        }
        
        if let phone = dict["phone"]?.string {
            self.phone = phone
        }
        
        if let snippetImageURL = dict["snippet_image_url"]?.string {
            self.snippetImageURL = snippetImageURL
        }
        
        if let id = dict["id"]?.string {
            self.id = id
        }
        
        if let ratingUrl = dict["rating_img_url"]?.string {
            self.ratingImgURL = ratingUrl
        }
        
        if let imageUrl = dict["image_url"]?.string {
            self.imageURL = imageUrl
        }
        
        if let claimed = dict["is_claimed"]?.bool {
            self.isClaimed = claimed
        }
        
        if let mobileUrl = dict["mobile_url"]?.string {
            self.mobileURL = mobileUrl
        }
        
        if let ratingUrl = dict["rating_img_url_small"]?.string {
            self.ratingImgURLSmall = ratingUrl
        }
        
        if let url = dict["url"]?.string {
            self.yelpURL = url
        }
        
        if let phone = dict["display_phone"]?.string {
            self.displayPhone = phone
        }
        
        if let ratingUrl = dict["rating_img_url_large"]?.string {
            self.ratingImgURLLarge = ratingUrl
        }
        
        if let closed = dict["is_closed"]?.bool {
            self.isClosed = closed
        }
        
        if let snippet = dict["snippet_text"]?.string {
            self.snippetText = snippet
        }
        
        if let distance = dict["distance"]?.double {
            self.distanceInMiles = distance/1600.0
        }
        
        if let name = dict["name"]?.string {
            self.name = name
        }
        
        if let location = dict["location"]?.dictionaryValue["display_address"]?.arrayValue {
            self.address = location.map{ $0.string! }
        }
    }
    
    var description : String {
        var s = [String]()
        for c in Mirror(reflecting: self).children
        {
            if let name = c.label {
                s.append("\(name) = \(c.value)")
            }
        }
        return s.joinWithSeparator(",")
    }
}