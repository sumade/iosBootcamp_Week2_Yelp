//
//  FilterViewController.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit


class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: UI Elements
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveFilterButton: UIBarButtonItem!
    @IBOutlet weak var filterTableView: UITableView!
    
    var distanceExpanded : Bool = false
    var categoryExpanded : Bool = false
    var sortByExpanded : Bool = false
    
    let categoriesNotExpandedLimit = 9
    
    // MARK: filter elements
    var filter : Filter.FilterSettings = Filter.FilterSettings()
    var filterHandler : ((Filter.FilterSettings?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.estimatedRowHeight = 100
        filterTableView.rowHeight = UITableViewAutomaticDimension
        filterTableView.estimatedSectionHeaderHeight = 20
        filterTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        filterTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        self.title = "Filter"
        
        // add buttons
        let saveBarButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "saveButtonTapped:")
        let cancelBarButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel" , style: .Done, target: self, action: "cancelButtonTapped:")
        
        saveBarButton.setTitleTextAttributes([NSForegroundColorAttributeName:MyColors.CalGold], forState: .Normal)
        cancelBarButton.setTitleTextAttributes([NSForegroundColorAttributeName:MyColors.CalGold], forState: .Normal)
        
        self.navigationItem.setRightBarButtonItems([saveBarButton], animated: true)
        self.navigationItem.setLeftBarButtonItem(cancelBarButton, animated: true)
        
        
        self.filterTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: table funcs
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Filter.filterSectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionType = Filter.FilterSections(rawValue: section) {
            switch sectionType {
                case .Deal: return 1
                case .Distance: return distanceExpanded ? Filter.distanceLabelText.count : 1
                case .SortBy: return sortByExpanded ? Filter.sortByLabelText.count : 1
                case .Category: return categoryExpanded ? YalpVars.condensedCategories.count : categoriesNotExpandedLimit+1
            }
        }else{
            print("unknown section \(section)")
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var returnCell : UITableViewCell?
        if let sectionType = Filter.FilterSections(rawValue: indexPath.section){
            switch sectionType {
            case .Deal:
                let cell = filterTableView.dequeueReusableCellWithIdentifier("FilterTableViewCell", forIndexPath: indexPath) as! FilterTableViewCell
                cell.infoLabel.text = Filter.dealLabelText
                cell.switchState.sectionId = indexPath.section
                cell.switchState.rowId = indexPath.row
                cell.switchState.setOn(filter.isOfferingADeal, animated: true)
                cell.switchState.addTarget(self, action: "switchDidToggle:", forControlEvents: UIControlEvents.ValueChanged)
                returnCell = cell
            case .Distance:
                let cell = filterTableView.dequeueReusableCellWithIdentifier("DropDownFilterTableViewCell", forIndexPath: indexPath) as! DropDownFilterTableViewCell
                if !distanceExpanded {
                    cell.selectionLabel.text = Filter.distanceLabelText[filter.distance.rawValue]
                    cell.selectionImage.image = UIImage(named: "expand")
                }else{
                    cell.selectionLabel.text = Filter.distanceLabelText[indexPath.row]
                    if indexPath.row == filter.distance.rawValue {
                        cell.selectionImage.image = UIImage(named: "selected")
                    }else{
                        cell.selectionImage.image = UIImage(named: "not-selected")
                    }
                }
                returnCell = cell
            case .SortBy:
                let cell = filterTableView.dequeueReusableCellWithIdentifier("DropDownFilterTableViewCell", forIndexPath: indexPath) as! DropDownFilterTableViewCell
                if !sortByExpanded {
                    cell.selectionLabel.text = Filter.sortByLabelText[filter.sortBy.rawValue]
                    cell.selectionImage.image = UIImage(named: "expand")
                }else{
                    cell.selectionLabel.text = Filter.sortByLabelText[indexPath.row]
                    if indexPath.row == filter.sortBy.rawValue {
                        cell.selectionImage.image = UIImage(named: "selected")
                    }else{
                        cell.selectionImage.image = UIImage(named: "not-selected")
                    }
                }
                returnCell = cell
            case .Category:
                if !categoryExpanded {
                    // first N entries are displayed
                    if indexPath.row == categoriesNotExpandedLimit {
                        // show "see all" cell
                        let cell = filterTableView.dequeueReusableCellWithIdentifier("DropDownFilterTableViewCell", forIndexPath: indexPath) as! DropDownFilterTableViewCell
                        cell.selectionLabel.text = "See All"
                        cell.selectionLabel.alpha =  0.6
                        cell.selectionImage.image = UIImage(named: "expand")
                        returnCell = cell
                    }
                }
                
                if categoryExpanded || (!categoryExpanded && indexPath.row < categoriesNotExpandedLimit) {
                    let cell = filterTableView.dequeueReusableCellWithIdentifier("FilterTableViewCell", forIndexPath: indexPath) as! FilterTableViewCell
                    cell.switchState.sectionId = indexPath.section
                    cell.switchState.rowId = indexPath.row
                    cell.infoLabel.text = YalpVars.categories[indexPath.row]["name"]
                    if let name = cell.infoLabel.text {
                        cell.switchState.setOn( filter.selectedCategories.contains(name), animated: true )
                    }else{
                        cell.switchState.setOn(false, animated: false)
                    }
                    cell.switchState.addTarget(self, action: "switchDidToggle:", forControlEvents: UIControlEvents.ValueChanged)
                    returnCell = cell
                }
            }
        }
        
        returnCell!.selectionStyle = .None
        return returnCell!
    }
    
    
    func switchDidToggle(mySwitch : UISwitch) -> Void {
        let myCustomSwitch = mySwitch as! MyCustomSwitch
        
        if let sectionType = Filter.FilterSections(rawValue: myCustomSwitch.sectionId){
            switch sectionType {
            case .Deal:
                filter.isOfferingADeal = myCustomSwitch.on
            case .Distance:
                if myCustomSwitch.on {
                    filter.distance = Filter.Distance(rawValue: myCustomSwitch.rowId)!
                }
            case .SortBy:
                if myCustomSwitch.on {
                    filter.sortBy = Filter.SortBy(rawValue: myCustomSwitch.rowId)!
                }
            case .Category:
                if myCustomSwitch.on {
                    if let name = YalpVars.categories[myCustomSwitch.rowId]["name"] {
                        if !filter.selectedCategories.contains(name) {
                            filter.selectedCategories.insert(name)
                        }
                    }
                }else {
                    if let name = YalpVars.categories[myCustomSwitch.rowId]["name"] {
                        if filter.selectedCategories.contains(name) {
                            filter.selectedCategories.remove(name)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var doRefresh : Bool = true
        if let sectionType = Filter.FilterSections(rawValue: indexPath.section) {
            switch sectionType {
            case .Deal :
                categoryExpanded = false
            case .Distance:
//                print("selected distance section")
                if distanceExpanded {
                    filter.distance = Filter.Distance(rawValue: indexPath.row)!
                    distanceExpanded = false
                }else{
                    distanceExpanded = true
                }
                categoryExpanded = false
            case .SortBy:
 //               print("selected sort by section")
                if sortByExpanded {
                    filter.sortBy = Filter.SortBy(rawValue: indexPath.row)!
                    sortByExpanded = false
                }else{
                    sortByExpanded = true
                }
                categoryExpanded = false
            case .Category:
//                print("selected category section")
                if !categoryExpanded {
                    if indexPath.row == categoriesNotExpandedLimit {
                        // user selected "see all", so expand the list
                        categoryExpanded = true
                        doRefresh = true
                    }
                }else{
                    // don't do anything because we don't want to collapse until the user clicks somewhere else
                    doRefresh = false
                }
            }
        }
        
        if doRefresh {
            filterTableView.reloadData()
        }
    }
    
    
    var distanceHeaderRecognizer = UITapGestureRecognizer()
    var sortByHeaderRecognizer = UITapGestureRecognizer()
    var categoryHeaderRecognizer = UITapGestureRecognizer()
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("SectionHeaderCell") as! SectionHeaderCell
        headerCell.alpha = 0.5
        
        headerCell.headerLabel.text = Filter.filterSectionNames[section]
        
        if let sectionType = Filter.FilterSections(rawValue: section) {
            switch sectionType {
            case .Deal:
                headerCell.headerLabel.text = nil
            case .Distance:
                distanceHeaderRecognizer.addTarget(self, action: "distanceHeaderTapped:")
                headerCell.addGestureRecognizer(distanceHeaderRecognizer)
            case .SortBy:
                sortByHeaderRecognizer.addTarget(self, action: "sortByHeaderTapped:")
                headerCell.addGestureRecognizer(sortByHeaderRecognizer)
            case .Category:
                categoryHeaderRecognizer.addTarget(self, action: "categoryHeaderTapped:")
                headerCell.addGestureRecognizer(categoryHeaderRecognizer)
            }
        }
        
        return headerCell
    }
    
    func distanceHeaderTapped(sender: UITapGestureRecognizer) -> Void {
        distanceExpanded = !distanceExpanded
        categoryExpanded = false
        filterTableView.reloadData()
    }

    func sortByHeaderTapped(sender: UITapGestureRecognizer) -> Void {
        sortByExpanded = !sortByExpanded
        categoryExpanded = false
        filterTableView.reloadData()
    }

    func categoryHeaderTapped(sender: UITapGestureRecognizer) -> Void {
        categoryExpanded = !categoryExpanded
        filterTableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        filterHandler?(nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        filterHandler?(filter)
        self.navigationController?.popViewControllerAnimated(true)
    }

}
