//
//  MapViewController.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/25/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!

    
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
        mapView.delegate = self
        // Do any additional setup after loading the view.
        self.refreshData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        
        self.refreshData()
    }
    
    @IBAction func logoutActionButton(sender: AnyObject) {
        
        if(FBSDKAccessToken.currentAccessToken() != nil){
            let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
        }
        
        UdacityAPIClient.sharedInstance().logoutSession(){ success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if success{
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    if(errorString == "The Internet connection appears to be offline."){
                        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)                        
                    }
                }
            }
        }
    }
    
    func refreshData(){
        
        self.view.userInteractionEnabled = false
        progressBarDisplayer("Loading Data", true)
        
        UdacityAPIClient.sharedInstance().getStudentLocations(){ success, error in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.messageFrame.removeFromSuperview()
                self.view.userInteractionEnabled = true
                
                if success{
                    
                    //http://stackoverflow.com/questions/10865088/how-do-i-remove-all-annotations-from-mkmapview-except-the-user-location-annotati
                    let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
                    self.mapView.removeAnnotations( annotationsToRemove )
                    
                    for result in StudentLocationStore.sharedInstance().studentInformations!{
                        
                        let studLoc =  StudentLocationAnnotation(title: "\(result.firstName) \(result.lastName)", mediaURL: result.mediaURL, coordinate: CLLocationCoordinate2D(latitude: result.latitude,longitude: result.longitude))
                        
                        self.mapView.addAnnotation(studLoc)
                    }
                }
                else{
                    
                    if((error?.code)! == -1009 && error?.localizedDescription == "The Internet connection appears to be offline."){
                        let alertController = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    else{
                        let alertController = UIAlertController(title: nil, message: "Error getting locations", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            })
            
        }
        
    }

    @IBAction func postButtonFromMaps(sender: AnyObject) {
        
        UdacityAPIClient.sharedInstance().checkForPreviousPost(){ success,error in
            
            if success == true{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alertController = UIAlertController(title: nil, message: "User \"\(UdacityAPIClient.sharedInstance().firstName!) \(UdacityAPIClient.sharedInstance().lastName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default) {
                        UIAlertAction in

                        self.performSegueWithIdentifier("map", sender: true)
                        
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                        UIAlertAction in
                        return
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                })
            }
            else{
                self.performSegueWithIdentifier("map", sender: false)
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "map"){
            let postVC = segue.destinationViewController as? PostViewController
            
            postVC?.mapVC = self
            postVC?.updatePost = sender as! Bool
        }
        
    }

}
