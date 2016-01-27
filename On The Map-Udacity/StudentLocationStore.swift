//
//  StudentLocationStore.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/30/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import Foundation

class StudentLocationStore : NSObject {
    
    var studentInformations: [StudentInformation]?
    
    class func sharedInstance() -> StudentLocationStore {
        
        struct Singleton {
            static var sharedInstance = StudentLocationStore()
        }
        
        return Singleton.sharedInstance
    }
}