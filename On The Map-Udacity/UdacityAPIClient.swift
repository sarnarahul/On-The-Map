//
//  UdacityAPIClient.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/17/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import Foundation

// MARK: - UdacityAPIClient: NSObject

class UdacityAPIClient : NSObject {
    
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    var config = TMDBConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userKeyID : String? = nil
    var objectID : String? = nil
    
    var firstName: String? = nil
    var lastName: String? = nil
    
    var updatePost:Bool = false
    
    //Student Locations
    var studentLocations: [[String:AnyObject]]?
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        studentLocations = [[String:AnyObject]]()
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(initialURL: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 2/3. Build the URL and configure the request */
        let urlString = initialURL + method + UdacityAPIClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        if(initialURL == Constants.BaseURLSecure){
        }
        else{
            request.addValue(UdacityAPIClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityAPIClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                
                completionHandler(result: nil, error: error)
                
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var errorString: String? = ""
                if let response = response as? NSHTTPURLResponse {
                    errorString = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorString = "Your request returned an invalid response!"
                }
                
                print(errorString!)
                
                let userInfo = [NSLocalizedDescriptionKey : errorString!]
                completionHandler(result: nil, error: NSError(domain: "Invalid Request", code: 1, userInfo: userInfo))
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if(initialURL == Constants.BaseURLSecure){
                UdacityAPIClient.parseUdacityJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
            else{
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(initialURL: String, method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        
        /* 2/3. Build the URL and configure the request */
        let urlString = initialURL + method + UdacityAPIClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if(initialURL == Constants.BaseURLSecure){
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        else{
            request.addValue(UdacityAPIClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityAPIClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        
        if(jsonBody.count != 0){
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            }
            catch{
                print("parsing Error") 
            }
        }
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                
                completionHandler(result: nil, error: error)
                
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var errorString: String? = ""
                if let response = response as? NSHTTPURLResponse {
                    errorString = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorString = "Your request returned an invalid response!"
                }
                
                print(errorString!)
                
                let userInfo = [NSLocalizedDescriptionKey : errorString!]
                completionHandler(result: nil, error: NSError(domain: "Invalid Request", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if(initialURL == Constants.BaseURLSecure){
                UdacityAPIClient.parseUdacityJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
            else{
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(initialURL: String, method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        
        /* 2/3. Build the URL and configure the request */
        let urlString = initialURL + method + UdacityAPIClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if(initialURL == Constants.BaseURLSecure){
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        else{
            request.addValue(UdacityAPIClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityAPIClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        do {
            if(jsonBody.count != 0){
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            }
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
                        
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                
                completionHandler(result: nil, error: error)
                
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var errorString: String? = ""
                if let response = response as? NSHTTPURLResponse {
                    errorString = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorString = "Your request returned an invalid response!"
                }
                
                print(errorString!)
                
                let userInfo = [NSLocalizedDescriptionKey : errorString!]
                completionHandler(result: nil, error: NSError(domain: "Invalid Request", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if(initialURL == Constants.BaseURLSecure){
                UdacityAPIClient.parseUdacityJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
            else{
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    //Mark: Delete
    
    func taskForDeleteSession(completionHandler: (success: Bool, errorString: String?) ->  Void) -> NSURLSessionTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                if(error == -1009 && error?.localizedDescription == "The Internet connection appears to be offline."){
                    completionHandler(success: false, errorString: error?.localizedDescription)
                }else{
                    completionHandler(success: false, errorString: "Error logging out")
                }
                
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Authentication Udacity Helper: Given raw JSON, return a usable Foundation object */
    class func parseUdacityJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityAPIClient {
        
        struct Singleton {
            static var sharedInstance = UdacityAPIClient()
        }
        
        return Singleton.sharedInstance
    }
}

// MARK: http://stackoverflow.com/questions/30743408/check-for-internet-connection-in-swift-2-ios-9
import SystemConfiguration

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
