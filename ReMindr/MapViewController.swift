//
//  MapViewController.swift
//  ReMindr
//
/*
 This view is used to control a map view where the annotations for each location is placed. A tinted radius (circle) is placed around each annotation to represent the custom radius. Geofencing is performed only if the notification switch was set on.
 Credits: Tutorials by Matthew Kairys (locations, annotations, geofencing)
 StackOverflow (MKCircle)
 */

//  Created by Priyanka Gopakumar on 28/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import UserNotifications

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
        
        let locationManager = CLLocationManager()
        var ref: FIRDatabaseReference!
        @IBOutlet weak var mapView: MKMapView!
    
        var favouriteList: NSMutableArray
        //var currentCategory: Category?
        var selectedPosition: Int?
        var selectedFavourite: Favourite?

    
        required init?(coder aDecoder: NSCoder)
        {
            self.favouriteList = NSMutableArray()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            super.init(coder: aDecoder)
        }
    
        override func viewDidLoad() {
            
            super.viewDidLoad()
            ref = FIRDatabase.database().reference()
            // checking if network is available (Reachability class is defined in another file)
            if Reachability.isConnectedToNetwork() == true      // if data network exists
            {
                print("Internet connection OK")
                viewWillAppear(true)
            }
            else        // if data network isn't available show an alert
            {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            // Setup delegation so we can respond to MapView and LocationManager events
            mapView.delegate = self
            locationManager.delegate = self
            
            // Ask user for permission to use location
            // Uses description from NSLocationAlwaysUsageDescription in Info.plist
            locationManager.requestAlwaysAuthorization()
            
            mapView.showsUserLocation = true
            print ("calling the patient location function")
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            //print ("calling the patient location function")
            //plotPatientLocationOnMap()
            /* looping through the category list to get the latitude and longitude values of the favourites from the list and plotting the annotations on the map.
             */
            
            plotPatientLocationOnMap()
            
            for currentFav in favouriteList
            {
                let fav = currentFav as! Favourite
                //print ("if lat \(fav.lat)")
                if (fav.lat! != "nil")
                {
                    let lat = Double(fav.lat!)
                    let lng = Double(fav.lng!)
                    let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                    //let notificationOn = Int(cat.notificationOn!) == 1 ? true:false
                    //let notificationRadius = Double(cat.notifcationRadius!)
                    let notificationRadius = 500
                    
                    //print("lat: \(lat)   lng: \(lng)")

                    let region = (name: fav.title, coordinate:loc)
                    let mapAnnotation = MKPointAnnotation()
                    mapAnnotation.coordinate = region.coordinate
                    mapAnnotation.title = region.name
                    mapView.addAnnotation(mapAnnotation)
                    
                    
                    /* Not implementing geofencing for the caregiver app
 
                    // set geofencing only if the user has chosen to keep notifications on
                    //if (notificationOn)
                    //{
                        let geofence = CLCircularRegion(center: region.coordinate, radius: CLLocationDistance(notificationRadius), identifier: region.name!)
                        locationManager.startMonitoring(for: geofence)
                        
                        // adding a range circle around the annotation (credits given below)
                        let circle = MKCircle(center: loc, radius: CLLocationDistance(notificationRadius) as CLLocationDistance)
                        self.mapView.add(circle)

                    //}
 
                */
                    
                }
            }
            
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    
        // A function to remove geofencing for categories that have been removed from the database
        func removeGeofencingForFavourite(favourite: Favourite)
        {
            if (favourite.lat != "nil")
            {
                let lat = Double(favourite.lat!)
                let lng = Double(favourite.lng!)
                let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                //let notificationOn = Int(category.notificationOn!) == 1 ? true:false
                //let notificationRadius = Double(category.notifcationRadius!)
                let notificationRadius = 500
                let region = (name: favourite.title, coordinate:loc)
                
                // set geofencing only if the user has chosen to keep notifications on
                //if (notificationOn)
                //{
                    let geofence = CLCircularRegion(center: region.coordinate, radius:  CLLocationDistance(notificationRadius), identifier: region.name!)
                    locationManager.stopMonitoring(for: geofence)
                //}
            }
        }
        
        // MARK: MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // Zoom to new user location when updated
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = mapView.userLocation.coordinate
            mapRegion.span = mapView.region.span; // Use current 'zoom'
            mapView.setRegion(mapRegion, animated: true)
        }
    
    
        // MARK: CLLocationManagerDelegate
        private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            // Only show user location in MapView if user has authorized location tracking
            mapView.showsUserLocation = (status == .authorizedAlways)
        }
    
    /*
        /*
         To notify a user when a category region is entered
         Source: Tutorials by Matthew Kairys
         */
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            print("I have entered \(region.identifier)")
            
            // Notify the user when they have entered a region
            let title = "ReMindr"
            let message = "You have a memory attached to this location : \(region.identifier)."
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            }
            else {
                
                // App is inactive, show a notification
            
                let content = UNMutableNotificationContent()
                content.title = "ReMindr"
                content.body = "YOU HAVE favourite attached to this location : \(region.identifier)"
                
                content.sound = UNNotificationSound.default()
                //content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
                
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                
                let request = UNNotificationRequest.init(identifier: "FiveSecondNotification", content: content, trigger: trigger)
                
                // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                
                center.add(request, withCompletionHandler: {(error) in
                    if let error = error {
                        print("Uh oh! We had an error: \(error)")
                    }
                })
            
//                UNNotificationRequest
//                let notification = UILocalNotification()
//                notification.alertTitle = title
//                notification.alertBody = message
//                UIApplication.shared.present
//                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
 
 */
    
    
    /*
        /*
         To notify a user when a category region is exited
         Source: Tutorials by Matthew Kairys
         */
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            print("Exited region \(region.identifier)")
            // Notify the user when they have entered a region
            let title = "ReMindr"
            let message = "You are leaving a location with an attached memory : \(region.identifier)."
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
            
        }
    */
    
        /*
         CREDITS:
         Customizing the circle overlay
         Source: http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview
         Answered By - vladCovaliov
         Edited By - Ben Trengrove
         Website - StackOverflow
         Date retrieved - 08/09/2016
         */
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer! {
            if overlay is MKCircle
            {
                let circle = MKCircleRenderer(overlay: overlay)
                circle.strokeColor = UIColor.red
                circle.fillColor = UIColor.orange.withAlphaComponent(0.3)
                circle.lineWidth = 1
                return circle
            }
            else
            {
                return nil
            }
        }
        
        
        /*
         A function to perform an action if the user clicks on an annotation. A detail discloure button is shown to the user.
         Source: https://www.hackingwithswift.com/example-code/location/how-to-add-a-button-to-an-mkmapview-annotation
         
         */
    
    
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation
            {
                return nil
            }
            else if annotation is CustomPointAnnotation
            {
                let cpa = annotation as! CustomPointAnnotation
                let patPinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
                print("cpa.imageName : \(cpa.imageName!)")
                patPinAnnotationView.canShowCallout = true
                patPinAnnotationView.image = #imageLiteral(resourceName: "patient")
                
                return patPinAnnotationView
            }
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinAnnotationView
        }
        
        /*
         When the detail disclosure right callout button is clicked, the flows is directed to the details view for the chosen category
         Source: https://www.hackingwithswift.com/example-code/location/how-to-add-a-button-to-an-mkmapview-annotation
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if (control == view.rightCalloutAccessoryView)
            {
                for favourite in (favouriteList as NSArray as! [Favourite])
                {
                    if favourite.title == (view.annotation?.title)!
                    {
                        selectedFavourite = favourite
                    }
                }
                print(selectedFavourite?.title)
                self.performSegue(withIdentifier: "ViewAnnotationSegue", sender: self)
            }
        }
    
   
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewAnnotationSegue")
        {
            print(selectedFavourite?.title ?? "nothing")
            let destinationVC = segue.destination as! FavouriteOnlyViewController
            // let destinationVC: ItemTableViewController = segue.destinationViewController as! ItemTableViewController
            destinationVC.currentFavourite = selectedFavourite
        }
    }

    func plotPatientLocationOnMap()
    {
        let patMarker = CustomPointAnnotation()
        ref.child("users").observe(.value, with: { (snapshot) in
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                print ("username \(username)")
                if (username == "testpatient")
                {
                    if let patientLat = value?["patLat"] as? String {
                        if let patientLng = value?["patLng"] as? String {
                            
                            print ("lat and lng for patient \(patientLat) \(patientLng)")
                            patMarker.coordinate = CLLocationCoordinate2D(latitude: Double(patientLat)!, longitude: Double(patientLng)!)
                            patMarker.title = "Patient Location"
                            patMarker.subtitle = "My patient is here"
                            patMarker.imageName = "heart"
                            
                            self.mapView.addAnnotation(patMarker)
                        }
                    }
                    
                }
            }
        })
    }

}


