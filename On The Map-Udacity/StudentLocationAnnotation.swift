//
//  StudentLocationAnnotation.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/26/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import Foundation

import MapKit

class StudentLocationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, mediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = mediaURL
        self.coordinate = coordinate
        
        super.init()
    }
}