## Yelp

This is a Yelp search app using the [Yelp API](https://www.yelp.com/developers/documentation/v2/search_api)

Time spent: `20`

### Features
- view restaurants information (& only restaurants) from yelp
- can search restaurant list; search queries pull data as the user types
- can alter the restaurant list via filters on any combination of:
   - whether the restaurant is offering deals
   - the sort order
   - the distance from your location
   - the category, or cuisine, of choice
- auto-layouts are used everywhere so that the app will work regardless of orientation or ios hardware
- the location for queries is sourced using gps... if allowed. If not, then the location is somewhere in the soma district of San Francisco.
- app icon changed (iphone6 / ios8+)
- app launch screen changed (iphone6 / ios8+)
- images are loaded asynchronously
- a loading display appears while network activity is happening in the background
- 
#### Required

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height
   - [x] Custom cells should have the proper Auto Layout constraints
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [x] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), radius (meters), deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] You can use the default UISwitch for on/off states. Optional: implement a custom switch
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [x] Display some of the available Yelp categories (choose any 3-4 that you want).

#### Optional

- [-] Search results page
   - [x] Infinite scroll for restaurant results
   - [ ] Implement map view of restaurant results
- [-] Filter page
   - [ ] Radius filter should expand as in the real Yelp app
   - [x] Categories should show a subset of the full list with a "See All" row to expand. Category list is here: http://www.yelp.com/developers/documentation/category_list (Links to an external site.)
- [ ] Implement the restaurant detail page.

### Walkthrough

General Walkthrough

![Video Walkthrough](yalp/YalpWalkthrough.gif)

Walkthrough showing layout consistency as orientation changes

![Video Walkthrough](yalp/YalpWalkthrough_Orientation.gif)


### Credits
* [Yelp API](https://www.yelp.com/developers/documentation/v2/search_api)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
* confirm by Nikolay Necheuhin from the Noun Project
* expanding by ChangHoon Baek from the Noun Project
* My wife for not getting upset at the time I spent on this project
* Homer Simpson for the his excellent reviews

