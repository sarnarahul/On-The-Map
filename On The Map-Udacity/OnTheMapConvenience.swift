//
//  OnTheMapConvenience.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/18/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import Foundation
import MapKit

extension UdacityAPIClient{
    
    
    // MARK: Authentication (GET) Methods
    /*
    Steps for Authentication...
    
    Step 1: Create a new request token
    Step 2a: Ask the user for permission via the website
    Step 3: Create a session ID
    */
    func authenticateWithViewController(loginVC: UIViewController, username:String?, password:String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        let parameters = [String:AnyObject]()
        
        let usernamePasswordDictionary: [String:String] = ["username":username!, "password": password!]
        
        var dict : [String: AnyObject] = [:]
        
        dict["udacity"] = usernamePasswordDictionary
        
        let jsonBody = dict
        
        taskForPOSTMethod(UdacityAPIClient.Constants.BaseURLSecure, method: Methods.Session, parameters: parameters, jsonBody: jsonBody){ JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {

                if(error.code == -1009 && error.localizedDescription == "The Internet connection appears to be offline."){
                    completionHandler(success: false, errorString: error.localizedDescription)
                }
                else{
                    completionHandler(success: false, errorString: error.domain)
                }

                //                completionHandler(success: false, error: error)
            } else {
                self.processSuccesfulLogin(JSONResult, completionHandler:completionHandler)
            }
        }
    }
    
    
    func logoutSession(completionHandler:(success: Bool, errorString: String?) -> Void){
        
        
        taskForDeleteSession(){ success, errorString in
            
            if success{
                completionHandler(success: true, errorString:nil)
            }
            else{
                completionHandler(success: false, errorString:errorString)
            }
            
        }
        
    }
    
    //MARK: FACEBOOK
    
    func authenticateWithFacebook(loginVC: UIViewController, token:String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        let token: [String:String] = [UdacityAPIClient.ParameterKeys.AccessToken:token!]
        
        var dict : [String: AnyObject] = [:]
        
        dict[UdacityAPIClient.ParameterKeys.FacebookMobile] = token
        
        let jsonBody = dict
        
        taskForPOSTMethod(UdacityAPIClient.Constants.BaseURLSecure, method: Methods.Session, parameters: parameters, jsonBody: jsonBody){ JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                if(error.code == -1009 && error.localizedDescription == "The Internet connection appears to be offline."){
                    completionHandler(success: false, errorString: error.localizedDescription)
                }
                else{
                    completionHandler(success: false, errorString: error.domain)
                }
                
                //                completionHandler(success: false, error: error)
            } else {
                self.processSuccesfulLogin(JSONResult, completionHandler:completionHandler)
            }
        }
    }
    
    func processSuccesfulLogin(JSONResult:AnyObject!, completionHandler: (success: Bool, errorString: String?) -> Void){
        if let jsonResult = JSONResult as? Dictionary<String, AnyObject> {
            
            let sessionJSON = jsonResult["session"]! as? Dictionary<String, AnyObject>
            let accountJSON = jsonResult["account"]! as? Dictionary<String, AnyObject>
            
            self.sessionID = sessionJSON!["id"]! as? String
            self.userKeyID = accountJSON!["key"]! as? String
            
            let parameters = [String:AnyObject]()
            
            print(jsonResult)
            
            taskForGETMethod(UdacityAPIClient.Constants.BaseURLSecure, method: "\(Methods.Users)\(self.userKeyID!)", parameters: parameters){ JSONResult, error in
                
                if let error = error{
                    if(error.code == -1009 && error.localizedDescription == "The Internet connection appears to be offline."){
                        completionHandler(success: false, errorString: error.localizedDescription)
                    }
                    else{
                        completionHandler(success: false, errorString: error.domain)
                    }
                }
                else{
                    let user = JSONResult["user"] as! [String:AnyObject]
                    
                    self.firstName = user["first_name"] as? String
                    self.lastName = user["last_name"] as? String
                    
                    completionHandler(success: true, errorString: nil)
                }
                
            }
            
        }
        else{
            completionHandler(success: false, errorString: "Authentication Failure")
        }
    }
    
    func getStudentLocations(completionHandler:(success:Bool, error:NSError!) -> Void){
        
        let parameters = [UdacityAPIClient.ParameterKeys.Limit : 100, "order": "-updatedAt"]
        
        taskForGETMethod(UdacityAPIClient.Constants.parseURLSecure, method: UdacityAPIClient.Methods.studentLocations, parameters: parameters){ JSONResult, error in
            
            //Error check
            if let error = error {
                
                if(error.code == -1009 && error.localizedDescription == "The Internet connection appears to be offline."){
                    completionHandler(success: false, error: error)
                }
                else{
                    completionHandler(success: false, error: error)
                }
              
                return
            }
            
            if let locations = JSONResult as? [String: AnyObject]{
                
                if let results = locations["results"] as? [[String : AnyObject]] {
                    
                    UdacityAPIClient.sharedInstance().studentLocations = results
                    StudentLocationStore.sharedInstance().studentInformations = StudentInformation.studentInfoFromResults(results)
                    StudentLocationStore.sharedInstance().studentInformations?.sortInPlace({ $0.updatedAt .compare($1.updatedAt) == .OrderedDescending })
                    
                    //http://stackoverflow.com/questions/31729337/swift-2-0-sorting-array-of-objects-by-property
                    
                    completionHandler(success: true, error: nil)
                } else {
                    
                    completionHandler(success: false, error: error)
                }
            }else{
                completionHandler(success: false, error: error)

            }
        }
    }
    
    func postStudentLocation(jsonBody:  [String:AnyObject], completionHandler:(success:Bool, error:NSError!) -> Void){
        
        let parameters = [String: AnyObject]()
        
        taskForPOSTMethod(UdacityAPIClient.Constants.parseURLSecure, method: UdacityAPIClient.Methods.studentLocations, parameters: parameters, jsonBody: jsonBody){ JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let jsonResult = JSONResult as? Dictionary<String, AnyObject> {
                    
                    if ((jsonResult[UdacityAPIClient.JSONResponseKeys.ObjectId]! as? String) != nil){
                        self.objectID = jsonResult[UdacityAPIClient.JSONResponseKeys.ObjectId]! as? String
                        completionHandler(success: true, error: nil)
                    }
                    else{
                        completionHandler(success: false, error: error)
                    }
                }
                else{
                    completionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func checkForPreviousPost(completionHandler:(success:Bool, error:NSError!) -> Void){
     
        let uniqueKeyDic = "{\"\(UdacityAPIClient.JSONResponseKeys.UniqueKey)\": \"\(self.userKeyID!)\"}"
        
        let parameters = [UdacityAPIClient.ParameterKeys.whereParam : uniqueKeyDic]
        
        taskForGETMethod(UdacityAPIClient.Constants.parseURLSecure, method: UdacityAPIClient.Methods.studentLocations, parameters: parameters){ JSONResult, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let jsonResult = JSONResult as? Dictionary<String, AnyObject> {
                    
                    if let results = jsonResult["results"] as? [[String : AnyObject]] {
                        
                        if(results.count != 0){
                            let result  = StudentInformation.studentInfoFromResults(results)[0]
                            print(result) 
                                if (result.uniqueKey != nil){
                                    self.objectID = result.objectId
                                    completionHandler(success: true, error: nil)
                                }
                        }
                        else{
                            let userInfo = [NSLocalizedDescriptionKey : "No Previous Post Found"]
                            completionHandler(success: false, error: NSError(domain: "Invalid Request", code: 1, userInfo: userInfo))
                        }
                    } else {
                        
                        completionHandler(success: false, error: error)
                    }
                }
                else{
                    completionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func updateStudentLocation(jsonBody:  [String:AnyObject], completionHandler:(success:Bool, error:NSError!) -> Void){
        
        let parameters = [String: AnyObject]()

        taskForPUTMethod(UdacityAPIClient.Constants.parseURLSecure, method: "\(UdacityAPIClient.Methods.studentLocations)/\(self.objectID!)", parameters: parameters, jsonBody: jsonBody){ JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let jsonResult = JSONResult as? Dictionary<String, AnyObject> {
                    
                    if ((jsonResult[UdacityAPIClient.JSONResponseKeys.UpdatedAt]! as? String) != nil){
                        completionHandler(success: true, error: nil)
                    }
                    else{
                        completionHandler(success: false, error: error)
                    }
                }
                else{
                    completionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func covertStringToJSON(jsonString:String?) -> [String: AnyObject]!{
        
        
        do{
            if let body = jsonString{
                return try NSJSONSerialization.JSONObjectWithData(body.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as! [String : AnyObject]
            }
            else{
                return [String:AnyObject]()
            }
        }
        catch{
            return [String:AnyObject]()
        }
    }
}