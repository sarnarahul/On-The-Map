//
//  ListTableViewController.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/27/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    var updateBool:Bool = false
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
                    self.tableView.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (StudentLocationStore.sharedInstance().studentInformations?.count)!
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        
        // Configure the cell... UITableViewCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell") //
        
        let location: StudentInformation = StudentLocationStore.sharedInstance().studentInformations![indexPath.row]
        
        cell.textLabel?.text = "\((location.firstName)!) \((location.lastName)!)"
        cell.detailTextLabel?.text = location.mediaURL!
        cell.imageView?.image = UIImage.init(named: "pin")

        return cell
    }
    
    
    override func tableView(tableView: UITableView,  didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location: StudentInformation = StudentLocationStore.sharedInstance().studentInformations![indexPath.row]

        if(UIApplication.sharedApplication().canOpenURL(NSURL(string:location.mediaURL!)!)){
            UIApplication.sharedApplication().openURL(NSURL(string:location.mediaURL!)!)
        }else{
            let alertController = UIAlertController(title: nil, message: "Invalid URL", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selected = false
    }

    @IBAction func postButtonFromList(sender: AnyObject) {
        UdacityAPIClient.sharedInstance().checkForPreviousPost(){ success,error in
            
            if success == true{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alertController = UIAlertController(title: nil, message: "User \"\(UdacityAPIClient.sharedInstance().firstName!) \(UdacityAPIClient.sharedInstance().lastName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        
                        self.performSegueWithIdentifier("list", sender: true)
                        
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
                self.performSegueWithIdentifier("list", sender: false)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "list"){
            let postVC = segue.destinationViewController as? PostViewController
            
            postVC?.listTVC = self
            postVC?.updatePost = sender as! Bool 
        }
        
    }


}
