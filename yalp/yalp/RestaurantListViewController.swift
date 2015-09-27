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
import MBProgressHUD

// 37.731753, -122.486846

extension String {
    func isSubstringOf(param: String) -> Bool {
        return param.rangeOfString(self, options: .CaseInsensitiveSearch) != nil
    }
}

class RestaurantlistViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    var locationManager = CLLocationManager()
    var yalpClient : YalpClient!
    
    var restaurants : [Restaurant] = [] {
        didSet {
            self.filteredRestaurants = restaurants
        }
    }
    
    var filteredRestaurants : [Restaurant] = [] {
        didSet {
            self.restaurantTableView.reloadData()
        }
    }
    
    var currentFilter : Filter.FilterSettings = Filter.FilterSettings() {
        didSet {
            print("new filter!")
            self.fetchData(currentFilter)
        }
    }

    // MARK: UI Elements
    var searchController: UISearchController!
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var filterButtonItem: UIBarButtonItem!
    

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // gps yo
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            print("auth status = \(CLLocationManager.authorizationStatus().rawValue)")
        }
        
        // make sure Yalp Client can connect
        if let yalpClient = YalpClient(consumerKey: YalpVars.YalpApiKeys.ConsumerKey.rawValue, consumerSecret: YalpVars.YalpApiKeys.ConsumerSecret.rawValue, accessToken: YalpVars.YalpApiKeys.Token.rawValue, accessSecret: YalpVars.YalpApiKeys.TokenSecret.rawValue) {
            self.yalpClient = yalpClient
        }else{
            // show error
            print("failed to load yalp client")
        }
        
        restaurantTableView.delegate = self
        restaurantTableView.dataSource = self
        restaurantTableView.estimatedRowHeight = 100
        restaurantTableView.rowHeight = UITableViewAutomaticDimension
        self.title = "Yalp"
        
        // search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Restaurants"
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        fetchData(nil)
    }

    // MARK: data fetch
    
    func fetchData(filter: Filter.FilterSettings?) {

        var parameters: Dictionary<String,String> = [:]
        
        // use current location, if available
        if let location = locationManager.location {
            parameters["ll"] = String("\(location.coordinate.latitude),\(location.coordinate.longitude)")
//            print("got actual location: \(location)")
        }
        
        if let filter = filter {
            print(filter)
        
            // add category filters
            let f1 = filter.selectedCategories.filter({ YalpVars.condensedCategories[$0.lowercaseString] != nil })
            print(f1)
            let f2 = f1.map{ YalpVars.condensedCategories[$0.lowercaseString]! }
            print(f2)
            
            let category_filters = filter.selectedCategories.filter({ YalpVars.condensedCategories[$0.lowercaseString] != nil })
                .map{ YalpVars.condensedCategories[$0.lowercaseString]! }
            
            if category_filters.count > 0 {
                parameters["category_filter"] = category_filters.joinWithSeparator(",")
            }
            
            // add deal filter
            if filter.isOfferingADeal {
                parameters["deals_filter"] = "true"
            }
            
            // add sortBy filter
            parameters["sort"] = String(filter.sortBy.rawValue)
            
            // add distance filter
            if filter.distance != .Auto {
                let radius = Filter.distanceToMilesDouble(filter.distance)
                parameters["radius_filter"] = String(radius*1600.0)
            }
        }
        
        /*
        // complicated logic to try and do search-as-type while also fetching new results
        var category_filters : [String] = []
        if let filters = filters {
            category_filters = filters.filter({ YalpVars.condensedCategories[$0.lowercaseString]})
            
//            category_filters = filters.filter({ YalpVars.condensedCategories[$0.lowercaseString] != nil })
//                .map{ YalpVars.condensedCategories[$0]! }
            // extension isSubstring
            category_filters = YalpVars.condensedCategories.filter({ (data: String) -> Bool in
                return data.rangeOfString(})
            filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
                return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
        }
        
        if filters != nil && category_filters.count > 0 {
            parameters["category_filter"] = category_filters.joinWithSeparator(",")
        }
        */
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "getting fud..."
        self.restaurantTableView.alpha = 0.5

        
        // always searching for restaurnts
        self.yalpClient.searchWithTerm("restaurants", parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                if let businesses = json["businesses"].array {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.restaurants = businesses.map{ Restaurant(dict: $0.dictionaryValue) }
                        self.restaurantTableView.alpha = 1.0
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    })
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                print(operation.responseObject)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: table methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRestaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = restaurantTableView.dequeueReusableCellWithIdentifier("RestaurantListTableCellTableViewCell", forIndexPath: indexPath) as! RestaurantListTableCellTableViewCell
        
        cell.selectionStyle = .None
        
        cell.restaurant = filteredRestaurants[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //movieTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: search methods
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       let searchText = searchController.searchBar.text

        print("searchText = \(searchText)")
        if let text = searchText {
            if text.isEmpty {
                filteredRestaurants = restaurants
                return
            }
        }
        
        if let searchWords = searchText?.componentsSeparatedByString(" ") {
            if searchWords.count > 0 {
                // for each restaurant
                filteredRestaurants = restaurants.filter({ (resto: Restaurant) -> Bool in
                    var result: Bool = false
                    
                    // for each search word, check if the search word is in the name of the restaurant
                    result = result ||
                        searchWords.filter({ return resto.name.rangeOfString($0, options: .CaseInsensitiveSearch) != nil }).count > 0
                    // for each search word, check if the search word in the name of the category
                    result = result ||
                        searchWords.filter({ (word: String) -> Bool in
                            return resto.categories.filter({
                                print("word is \(word) and category is \($0)")
                                return $0.rangeOfString(word, options: .CaseInsensitiveSearch) != nil
                            }).count>0
                        }).count>0
                    return result
                })
            }
        }
//        print(searchText)
        
        /*
        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
        */
    }
    
    /*
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        let searchText = searchBar.text
        fetchData(searchText?.componentsSeparatedByString(" "))
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("search clicked: \(searchBar.text)")
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("cancel clicked: \(searchBar.text)")
        filteredRestaurants = restaurants
    }

    */
    
    // MARK: Navigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToFilter" {
            let filterVC = segue.destinationViewController as! FilterViewController
            filterVC.filter = currentFilter
            filterVC.filterHandler = { (filter: Filter.FilterSettings?) -> Void in
                self.handleFilter(filter)
            }
        }
    }
    
    func handleFilter(filter: Filter.FilterSettings?) {
        if let filter = filter {
            // new filter configured
            currentFilter = filter
        }
    }
}

