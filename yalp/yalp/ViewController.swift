//
//  ViewController.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftyJSON

import CoreLocation

// 37.731753, -122.486846

class ViewController: UIViewController {

//    var locationManager : CLLocationManager!
    
    var locationManager = CLLocationManager()

    @IBOutlet weak var locationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // gps yo
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            print(locationManager.location)
        }else{
            print("auth status = \(CLLocationManager.authorizationStatus().rawValue)")
        }
        
        // test Yalp Client
        if let yalpClient = YalpClient(consumerKey: YalpVars.YalpApiKeys.ConsumerKey.rawValue, consumerSecret: YalpVars.YalpApiKeys.ConsumerSecret.rawValue, accessToken: YalpVars.YalpApiKeys.Token.rawValue, accessSecret: YalpVars.YalpApiKeys.TokenSecret.rawValue) {
            
            var parameters = ["limit":"1"]
            if let location = locationManager.location {
                parameters["ll"] = String("\(location.coordinate.latitude),\(location.coordinate.longitude)")
                locationLabel.text = parameters["ll"]
            }
            yalpClient.searchWithTerm("Thai", parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let json = JSON(responseObject)
                    dispatch_async(dispatch_get_main_queue(), {
                        print(json)
                    })
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    print("error: \(error)")
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

