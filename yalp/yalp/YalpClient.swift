//
//  YalpClient.swift
//  yalp
//
//  Created by Sumeet Shendrikar on 9/26/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import SwiftyJSON
import BDBOAuth1Manager

class YalpClient {
    
    private var oauthMgr: BDBOAuth1RequestOperationManager!
    
    init?(consumerKey: String, consumerSecret: String, accessToken: String, accessSecret: String) {
        
        let baseURL = NSURL(string:"http://api.yelp.com/v2/")
        
        if let oauthMgr = BDBOAuth1RequestOperationManager(baseURL: baseURL, consumerKey: consumerKey, consumerSecret: consumerSecret){
            if let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil) {
                if oauthMgr.requestSerializer.saveAccessToken(token) {
                    self.oauthMgr = oauthMgr
                }
            }
        }
        
        // fail if oauthMgr was not created
        if self.oauthMgr == nil {
            return nil
        }
    }
    
    
    func searchWithTerm(term: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) -> AFHTTPRequestOperation? {
                
        let defaultParams : NSDictionary = ["term": term, "ll":YalpVars.defaultCoordinates]
        let actualParams : NSMutableDictionary = [:]
        
        actualParams.addEntriesFromDictionary(defaultParams as [NSObject : AnyObject])
        if let parameters = parameters {
            if parameters.count > 0 {
                actualParams.addEntriesFromDictionary(parameters as [NSObject : AnyObject])
            }
        }
        
        print("actual parameters: \(actualParams)")
        
        return oauthMgr.GET("search", parameters: actualParams, success: success, failure: failure)
    }
}

