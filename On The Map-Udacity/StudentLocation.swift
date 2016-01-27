//
//  StudentLocation.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/26/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import UIKit

struct StudentInformation{
    
    var objectId: String!
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var createdAt: NSDate!
    var updatedAt: NSDate!
    var ACL: AnyObject!
    
    init(studentInformationDictionary: [String: AnyObject]){
        
        self.objectId = studentInformationDictionary["objectId"] as? String
        self.uniqueKey = studentInformationDictionary["uniqueKey"] as? String
        self.firstName = studentInformationDictionary["firstName"] as? String
        self.lastName = studentInformationDictionary["lastName"] as? String
        self.mapString = studentInformationDictionary["mapString"] as? String
        self.mediaURL = studentInformationDictionary["mediaURL"] as? String
        self.latitude = studentInformationDictionary["latitude"] as? Double
        self.longitude = studentInformationDictionary["longitude"] as? Double
    
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSxxx'Z'" /*find out and place date format from http://userguide.icu-project.org/formatparse/datetime*/
        self.updatedAt = dateFormatter.dateFromString((studentInformationDictionary["updatedAt"] as? String)!)
    }
    
    
    static func studentInfoFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var studentInfos = [StudentInformation]()
        
        for result in results {
            studentInfos.append(StudentInformation(studentInformationDictionary: result))
        }
        
        return studentInfos
    }
}