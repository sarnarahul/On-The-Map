//
//  PostViewController.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/27/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var enterLocationTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    var listTVC: ListTableViewController?
    var mapVC: MapViewController?
    
    var updatePost:Bool = false
    var locationName: String? = nil
    
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    //Mark: http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterLocationTextView.delegate = self
        websiteTextView.delegate = self
        
        mapView.hidden = true
        postButton.hidden = true
        
        websiteTextView.userInteractionEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func FindOnMapButton(sender: UIButton) {
        
            getLocationFromTextView()
            sender.hidden = true //this is working as the On the Map App on the App Store which hides this button once location found
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        
        if(self.websiteTextView.text == "" || self.websiteTextView.text == "Enter a Link to Share Here"){
            
            let alertController = UIAlertController(title: nil, message: "Empty Input Not Allowed", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        if(self.updatePost == true){
            self.updateStudentLocation()
        }
        else{
            self.postStudentLocation()
        }
    
    }
    
    func postStudentLocation(){
        
        let jsonBody:[String:AnyObject] = [
                "uniqueKey":UdacityAPIClient.sharedInstance().userKeyID!,
                "firstName": UdacityAPIClient.sharedInstance().firstName!,
                "lastName": UdacityAPIClient.sharedInstance().lastName!,
                "mapString": self.locationName!,
                "mediaURL": self.websiteTextView.text!,
                "latitude": self.pointAnnotation.coordinate.latitude,
                "longitude": self.pointAnnotation.coordinate.longitude
            ]
        
            UdacityAPIClient.sharedInstance().postStudentLocation(jsonBody as [String : AnyObject]){ success, error in
                
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: {
                            
                            if let listObject = self.listTVC{
                                listObject.refreshData()
                            }
                            
                            if let mapObject = self.mapVC{
                                mapObject.refreshData()
                            }
                        })
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if((error?.code)! == -1009 && error?.localizedDescription == "The Internet connection appears to be offline."){
                            dispatch_async(dispatch_get_main_queue(), {
                                let alertController = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alertController, animated: true, completion: nil)
                            })
                        }
                        else{
                            let alertController = UIAlertController(title: nil, message: "Submision Error", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })
                }
                
            }

    }

    func updateStudentLocation(){
//        let body = "{\"uniqueKey\": \"\(UdacityAPIClient.sharedInstance().userKeyID!)\", \"firstName\": \"\(UdacityAPIClient.sharedInstance().firstName!)\", \"lastName\": \"\(UdacityAPIClient.sharedInstance().lastName!)\",\"mapString\": \"\(self.enterLocationTextView.text)\", \"mediaURL\": \"\(self.websiteTextView.text!)\",\"latitude\": \(self.pointAnnotation.coordinate.latitude), \"longitude\": \(self.pointAnnotation.coordinate.longitude)}"
        
        let jsonBody = [
            "uniqueKey":UdacityAPIClient.sharedInstance().userKeyID!,
            "firstName": UdacityAPIClient.sharedInstance().firstName!,
            "lastName": UdacityAPIClient.sharedInstance().lastName!,
            "mapString": self.locationName!,
            "mediaURL": self.websiteTextView.text!,
            "latitude": self.pointAnnotation.coordinate.latitude,
            "longitude": self.pointAnnotation.coordinate.longitude
        ]
            UdacityAPIClient.sharedInstance().updateStudentLocation(jsonBody as! [String : AnyObject]){ success, error in
                
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: {
                            
                            if let listObject = self.listTVC{
                                listObject.refreshData()
                            }
                            
                            if let mapObject = self.mapVC{
                                mapObject.refreshData()
                            }
                        })
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if((error?.code)! == -1009 && error?.localizedDescription == "The Internet connection appears to be offline."){
                            dispatch_async(dispatch_get_main_queue(), {
                                let alertController = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alertController, animated: true, completion: nil)
                            })
                        }
                        else{
                            let alertController = UIAlertController(title: nil, message: "Submision Error", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })
                }
                
            }
        
    }

    
    func getLocationFromTextView(){
      
        self.view.userInteractionEnabled = false
        progressBarDisplayer("Loading Data", true)
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.enterLocationTextView.text 
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                    self.messageFrame.removeFromSuperview()
                    self.view.userInteractionEnabled = true
            })
            
            if (error != nil){
                let alertController = UIAlertController(title: nil, message: "Error finding location", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
//            let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)

            self.mapView.hidden = false
            self.enterLocationTextView.hidden = true
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation!.title = localSearchResponse?.mapItems[0].name
            self.locationName = localSearchResponse?.mapItems[0].name
            self.pointAnnotation!.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
            let annotationPoint = MKMapPointForCoordinate(self.pointAnnotation.coordinate);
            
            self.mapView.setVisibleMapRect(MKMapRectMake(annotationPoint.x,annotationPoint.y, 0.5, 0.5), animated: true)
            
            self.websiteTextView.userInteractionEnabled = true
            self.websiteTextView.text = "Enter a Link to Share Here"
            self.postButton.hidden = false
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        textView.text = ""
        textView.textAlignment = NSTextAlignment.Left
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.textAlignment = NSTextAlignment.Center
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
