//
//  VenueRegistrationTVC.swift
//  Chime
//
//  Created by William McDuff on 3/13/15.
//  Copyright (c) 2015 William McDuff. All rights reserved.
//

import UIKit

class VenueRegistrationTVC: UITableViewController {
    
    @IBOutlet weak var venueNameField: UITextField!
    @IBOutlet weak var venueAddressField: UITextField!
    @IBOutlet weak var venuePhoneField: UITextField!
    @IBOutlet weak var venueNeighborhoodField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var chimeLabel: UILabel!
    @IBOutlet weak var welcomeTextLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.clearColor()    // set tableview background to clear
        tableView.bounces = true   // stop tableView from bouncing
    
        view.backgroundColor = UIColor(red:0.81, green:0.96, blue:0.56, alpha:1)    // set background to green
        view.backgroundColor = UIColor.lightGrayColor()
        
        // load background image w/ gradient.
        let bgImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        
        let bgImage = UIImage(named: "greenBackground")
        bgImageView.image = bgImage
        
        tableView.backgroundView = bgImageView
        
        /////////
        /////////   SHIFT UI WITH KEYBOARD PRESENT
        /////////
        var keyboardHeight: CGFloat = 0
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                // move constraint
                keyboardHeight = kbSize.height

                let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
                self.tableView.contentInset = contentInsets
                self.tableView.scrollIndicatorInsets = contentInsets
//                self.tableView.scrollToRowAtIndexPath(NSIndexPath(index: 2), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                
                // animate constraint
                self.view.layoutIfNeeded()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            // move constraint back
            
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero

            self.view.layoutIfNeeded()
        } // end: keyboard shift
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // hide stuff for animations
        chimeLabel.hidden = true
        welcomeTextLabel.hidden = true
        backButton.hidden = true
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // animate the logo from the bottom
        let scale1 = CGAffineTransformMakeScale(0.5, 0.5)
        let translate1 = CGAffineTransformMakeTranslation(0, 400)
        self.chimeLabel.transform = CGAffineTransformConcat(scale1, translate1)
        
        animationWithDuration(2) {
            self.chimeLabel.hidden = false
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.chimeLabel.transform = CGAffineTransformConcat(scale, translate)
        }
        
        // animate the rest
       
              self.backButton.transform = CGAffineTransformConcat(scale1, translate1)
        self.welcomeTextLabel.transform = CGAffineTransformConcat(scale1, translate1)
        
        animationWithDuration(2) {
            self.backButton.hidden = false
            self.welcomeTextLabel.hidden = false
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.backButton.transform = CGAffineTransformConcat(scale, translate)
            self.welcomeTextLabel.transform = CGAffineTransformConcat(scale, translate)
        }
        
    }

    @IBAction func backToLoginVC(sender: AnyObject) {
        // dismiss TVC and go back to login
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    /////////
    /////////   LOG IN / SIGN UP
    /////////
    
    // need to connect this to storyboard
    @IBAction func checkFields(sender: AnyObject) {
        // email / pw field validation
        let fieldValues: [String] = [emailField.text!,passwordField.text!,venueNameField.text!,venueAddressField.text!,venuePhoneField.text!,venueNeighborhoodField.text!]
        if fieldValues.indexOf("") != nil {
            // all fields are not filled in, present alert
            let alertViewController = UIAlertController(title: "Submission Error", message: "Please fill in all fields.", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        } else {
            // all fields are filled in, check if user exists
            let userQuery = PFUser.query()
            userQuery.whereKey("email", equalTo: emailField.text)
            
            userQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if objects.count > 0 {
                    // user already exists, present error message
                    print("User already exists, presenting error alert...")

                    let aVC = UIAlertController(title: "Account Already Exists", message: "Please log in through the previous screen. This screen is for new account registration only.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    aVC.addAction(defaultAction)
                    self.presentViewController(aVC, animated: true, completion: nil)
                    
                } else {
                    // user not found, sign up user
                    print("Sign Up fields good...")
                    self.signUp()
                }
            })
        }
    }  // end: field validation
    
    
    func signUp() {
        // sign up user
        let user = PFUser()
        user.username = emailField.text
        user.password = passwordField.text
        user.email = emailField.text
        
        
        var location:CLLocation = CLLocation()
        
        location = GlobalVariableSharedInstance.currentLocation() as CLLocation
        
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as PFGeoPoint
        
        user["location"] = geoPoint // why are we saving the users location to Parse?
        
        // save venue info to user as well?
        user["isOwner"] = true
        user["venueName"] = venueNameField.text
        
        // TODO: add hometown / city to user when signing up..  though maybe just have them enter it.  could present alert asking "is Atlanta your hometown?" and then adding it if they click "yes"
        
        user.signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if error == nil {
                // sign up successful
                print("Parse: Sign up successful. New account created: \(user.username)")
                
                self.saveVenue()
                
            } else {
                // sign up failed
                let errorString = error.userInfo["error"] as! NSString
                print("Signup failed. Error message: \(errorString)")
                // present alert to user
                let alertViewController = UIAlertController(title: "Sign Up Error", message: "Our apologies! Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertViewController.addAction(defaultAction)
                self.presentViewController(alertViewController, animated: true, completion: nil)
                
            }
        }
    }  // end: sign up
    
    func saveVenue() {
        
        let address = self.venueAddressField.text
        
//        GlobalVariableSharedInstance.delegate = self
        
        GlobalVariableSharedInstance.addressToLocation(address!, completion: { (geoPoint) -> Void in
            
            if let geoPoint = geoPoint {
                
                let venueInfo:PFObject = PFObject(className: "Venues")
                venueInfo["venueName"] = self.venueNameField.text
                venueInfo["venueAddress"] = self.venueAddressField.text
                venueInfo["venueNeighborhood"] = self.venueNeighborhoodField.text
                venueInfo["venuePhone"] = self.venuePhoneField.text
                venueInfo["location"] = geoPoint
                venueInfo["venueOwner"] = PFUser.currentUser().email
                
                venueInfo.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    // venue is successfully saved to parse, dismiss vc
                    print("Venue registration succeeded. Venue created: \(self.venueNameField.text)")
                    
                    makeVibrate()
                    
                    // dismiss vc and push to navigationvc
                    if let nc = self.storyboard?.instantiateViewControllerWithIdentifier("navigationC") as? RootNavigationController {
//                        self.dismissViewControllerAnimated(true, completion: nil)   // necessary?
                        self.presentViewController(nc, animated: true, completion: nil)
                    }
                    
                })
            }
            
        })
        
    }
    
    // not sure what this does but it conforms us to the protocol..
    func didReceiveGeoPoint(location: PFGeoPoint) {
        print("didReceiveGeoPoint function ran...")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // dismiss keyboard when user touches outside textfields
        view.endEditing(true)
//        tableView.endEditing(true)
        super.touchesBegan(touches, withEvent: event)   // ?? is this necessary
    }

}
