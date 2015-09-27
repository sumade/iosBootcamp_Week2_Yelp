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
    
    // change in data should result in view refresh
    var restaurants : [Restaurant] = [] {
        didSet {
            self.restaurantTableView.reloadData()
        }
    }
    
    // change in search terms should trigger new fetch
    var currentSearchTerms : [String] = [] {
        didSet {
            self.fetchDataTask(currentFilter, newSearch: true)
            // put the table scroll at the top
            self.restaurantTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }

    // change in filter should trigger new fetch
    var currentFilter : Filter.FilterSettings = Filter.FilterSettings() {
        didSet {
            self.fetchDataTask(currentFilter, newSearch: true)
            // put the table scroll at the top
            self.restaurantTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    
    var isFetchInProgress : Bool = false
    var currentQueryRowIndex : Int = 0
    var currentQueryTotalRowCount : Int = 0
    
    var inTheMiddleOfQuery : Bool {
        return currentQueryTotalRowCount != 0
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
            print("!failed to load yalp client")
            // TODO: error
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
        
        fetchDataTask(nil, newSearch:true)
    }

    // MARK: data fetch
    
    // wrapper function that just calls the helper on a separate queue
    func fetchData(filter: Filter.FilterSettings?, newSearch: Bool) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "getting fud..."
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.fetchDataTask(filter, newSearch: newSearch)
        }
        
    }
    
    func fetchDataTask(filter: Filter.FilterSettings?, newSearch: Bool) {

        if isFetchInProgress {
//            print("fetch already in progress.")
            return
        }
        isFetchInProgress = true
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "getting fud..."

        var parameters: Dictionary<String,String> = [:]
        
        // use current location, if available
        if let location = locationManager.location {
            parameters["ll"] = String("\(location.coordinate.latitude),\(location.coordinate.longitude)")
//            print("got actual location: \(location)")
        }
        
        if let filter = filter {
            //print(filter)
        
            // add category filters
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
        
        var terms : String = "restaurants"
        if self.currentSearchTerms.count > 0 {
            terms = terms + "," + self.currentSearchTerms.joinWithSeparator(",")
        }
        
        if newSearch {
            self.currentQueryTotalRowCount = 0
            self.currentQueryRowIndex = 0
            self.restaurantTableView.alpha = 0.5
        }
        
        if self.inTheMiddleOfQuery {
            parameters["offset"] = String(self.currentQueryRowIndex)
        }
        

        // yalp go
        self.yalpClient.searchWithTerm(terms, parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                if let businesses = json["businesses"].array, let total=json["total"].int {
                    let newSet = businesses.map{ Restaurant(dict: $0.dictionaryValue) }
                    dispatch_async(dispatch_get_main_queue(), {
                        if !self.inTheMiddleOfQuery {
                            self.currentQueryTotalRowCount = total
                            self.currentQueryRowIndex = newSet.count
                            self.restaurants = newSet
                        }else{
                            self.currentQueryRowIndex += newSet.count
                            self.restaurants.appendContentsOf(newSet)
                        }
                        self.isFetchInProgress = false
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
        return min(restaurants.count, currentQueryRowIndex, currentQueryTotalRowCount)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = restaurantTableView.dequeueReusableCellWithIdentifier("RestaurantListTableCellTableViewCell", forIndexPath: indexPath) as! RestaurantListTableCellTableViewCell
        
        // check if more data needs to be fetched
        if currentQueryRowIndex < currentQueryTotalRowCount {
            let limit = 0.60*Double(currentQueryRowIndex)
            if indexPath.row >= Int(limit) {
                // fetch when 60% is shown
                fetchDataTask(currentFilter, newSearch:false)
            }
        }
        
        cell.selectionStyle = .None
        cell.restaurant = restaurants[indexPath.row]

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //movieTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: search methods
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       let searchText = searchController.searchBar.text

        if let text = searchText {
            if text.isEmpty {
                //restaurants = restaurants
                self.currentSearchTerms = []
                return
            }
        }
        
        /*
        // checks for the search terms in the restaurant name, or in the restaurant category set
        if let searchWords = searchText?.componentsSeparatedByString(" ") {
            if searchWords.count > 0 {
                // for each restaurant
                searchBarFilteredRestaurants = restaurants.filter({ (resto: Restaurant) -> Bool in
                    var result: Bool = false
                    
                    // for each search word, check if the search word is in the name of the restaurant
                    result = result ||
                        searchWords.filter({ return resto.name.rangeOfString($0, options: .CaseInsensitiveSearch) != nil }).count > 0
                    // for each search word, check if the search word in the name of the category
                    result = result ||
                        searchWords.filter({ (word: String) -> Bool in
                            return resto.categories.filter({
                                return $0.rangeOfString(word, options: .CaseInsensitiveSearch) != nil
                            }).count>0
                        }).count>0
                    return result
                })
            }
        }
        */
        if let currentSearchTerms = searchText?.componentsSeparatedByString(" ") {
            if currentSearchTerms.count > 0 {
                self.currentSearchTerms = currentSearchTerms
            }
        }
        
    }
    
    /*
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        let searchText = searchBar.text
        fetchData(searchText?.componentsSeparatedByString(" "))
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("search clicked: \(searchBar.text)")
    }
    */
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        restaurantTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
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

