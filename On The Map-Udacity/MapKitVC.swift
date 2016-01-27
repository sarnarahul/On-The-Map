//
//  MapKitVC.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/26/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    // 1
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? StudentLocationAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = annotationView.annotation as? StudentLocationAnnotation {
            
            if (control == annotationView.rightCalloutAccessoryView) {
                if(UIApplication.sharedApplication().canOpenURL(NSURL(string: annotation.subtitle!)!)){
                    UIApplication.sharedApplication().openURL(NSURL(string: annotation.subtitle!)!)
                }
                else{
                    let alertController = UIAlertController(title: nil, message: "Invalid URL", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }            
        }
    }
}