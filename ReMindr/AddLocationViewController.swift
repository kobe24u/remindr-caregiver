//
//  AddLocationViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//   YO

import UIKit
import MapKit

protocol geofenceLocationDelegate {
    func addGeofenceLocation(locLat: Double, locLng: Double)
}

class AddLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
        
        let locationManager = CLLocationManager()
        var lat : Double?
        var lng : Double?
        var favName: String?
        var delegate: geofenceLocationDelegate?
        var progressView = UIView()
        var isFirstTime: Bool = true
    
        @IBOutlet weak var textAddress: UITextField!
        @IBOutlet weak var mapView: MKMapView!
        
        required init?(coder aDecoder: NSCoder) {
            lat = nil
            lng = nil
            favName = nil
            super.init(coder: aDecoder)
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setProgressView()
            isFirstTime = true
            self.textAddress.delegate = self
            //Looks for single or multiple taps.
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            view.addGestureRecognizer(tap)
            
            // checking if network is available (Reachability class is defined in another file)
            if Reachability.isConnectedToNetwork() == true      // if data network exists
            {
                print("Internet connection OK")
            }
            else
            {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            // Setup delegation so we can respond to MapView and LocationManager events
            mapView.delegate = self
            locationManager.delegate = self
            
            mapView.showsUserLocation = true
            
            // remove all annotations
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            // Ask user for permission to use location
            // Uses description from NSLocationAlwaysUsageDescription in Info.plist
            locationManager.requestAlwaysAuthorization()
            
            // for gesture recognition
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationViewController.manualAssignAnnotation(gestureRecognizer:)))
            gestureRecognizer.delegate = self
            self.mapView.addGestureRecognizer(gestureRecognizer)
            
            // put an annotation in case of edit favourite
            addPreviousAnnotation()
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            // checking if network is available (Reachability class is defined in another file)
            if Reachability.isConnectedToNetwork() == true      // if data network exists
            {
                print("Internet connection OK")
            }
            else
            {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
        /*SOURCE : http://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
         Author : Moriya
         Retrieved on: 09/09/2016
         
         This method is used to allow the user to manually set annotations on the map by clicking on it.
         The latitude and longitute of the point is recorded in the class variables
         and an annotation is placed on the map
         */
        func manualAssignAnnotation(gestureRecognizer: UILongPressGestureRecognizer)
        {
            // remove all annotations
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = self.mapView.convert(location, toCoordinateFrom: mapView)
            
            // saving coordinates of the location clicked
            self.lat = coordinate.latitude
            self.lng = coordinate.longitude
            
            print("manual lat and lng : \(lat)   \(lng)")
            // Add annotation on the map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
        /*
         Puts an annotation on the map if the current favourite had a previous location assigned to it
         */
        func addPreviousAnnotation()
        {
            if (lat != nil)     // if it has a previous latitude
            {
                let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                
                print("lat: \(lat)   lng: \(lng)")
                
                let region = (name: favName, coordinate:loc)
                let mapAnnotation = MKPointAnnotation()
                mapAnnotation.coordinate = region.coordinate
                mapAnnotation.title = region.name
                mapView.addAnnotation(mapAnnotation)
                // zooming into the area near the annotation
                let area = MKCoordinateRegion(center: loc , span: MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01))
                mapView.setRegion(area, animated: true)
            }
        }
        
        
        /*
         This method is invoked when the user clicks on the search button after entering an address.
         The code has been sourced from StackOverflow and tutorials by Matthew Kairys.
         Retrieved from: http://stackoverflow.com/questions/24706885/how-can-i-plot-addresses-in-swift-converting-address-to-longitude-and-latitude
         Author: agf119105
         Date: 05/09/2016
         */
    @IBAction func findAddressCoordinates(_ sender: Any) {
        searchForAddressCoordinates()
    }
    
        // MARK: MKMapViewDelegate
        func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
            // Zoom to new user location when updated first time
            
            if (isFirstTime)
            {
                var mapRegion = MKCoordinateRegion()
                mapRegion.center = mapView.userLocation.coordinate
                mapRegion.span = mapView.region.span; // Use current 'zoom'
                mapView.setRegion(mapRegion, animated: true)
            }
            isFirstTime = false
        }
        
        // MARK: CLLocationManagerDelegate
        private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            // Only show user location in MapView if user has authorized location tracking
            mapView.showsUserLocation = (status == .authorizedAlways)
        }
    
    /*
        /*
         To notify the user when he enters a region marked by the category.
         Credits: Matthew Kairys
         */
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            print("Entered region \(region.identifier)")
            
            // Notify the user when they have entered a region
            let title = "Entered new region"
            let message = "You have arrived at \(region.identifier)."
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
        
        /*
         Function that detects if a user has left a geofencing  region.
         Credits: Matthew Kairys
         */
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            print("Exited region \(region.identifier)")
        }
        
 */
    
        /*
         This funtion is invoked when the users confirms the location by clicking on the confirm button.
         The lat and lng values are sent back to the previous view through the delegate.
         */
    
    
    @IBAction func saveGeofenceLocation(_ sender: Any) {
        
        if let locationLatitude = lat {
            self.delegate!.addGeofenceLocation(locLat: locationLatitude, locLng: lng!)
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            displayAlertMessage(title: "Alert", message: "You must assign a location")
        }

    }
    
        @IBAction func saveLocation(_ sender: Any) {
            
            
        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
    
    /*
     A function to allow custom alerts to be created by passing a title and a message
     */
    func displayAlertMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        searchForAddressCoordinates()
        return true
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
         // Zoom to new user location when updated
        if (isFirstTime)
        {
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = mapView.userLocation.coordinate
            //mapRegion.span = MKSpan
            mapView.setRegion(mapRegion, animated: true)
        }
        isFirstTime = false
    }
    
    func searchForAddressCoordinates()
    {
        self.view.endEditing(true)
        // remove all annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let address = textAddress.text
        
        if (!((address?.isEmpty)!))
        {
            view.addSubview(progressView)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address!, completionHandler: { (placemarks: [CLPlacemark]?, error) -> Void in
                if error == nil
                {
                    if placemarks!.count > 0
                    {
                        let topResult: CLPlacemark = (placemarks?[0])!
                        let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = (placemark.location!.coordinate)
                        
                        var region: MKCoordinateRegion = self.mapView.region
                        
                        region.center.latitude = (placemark.location?.coordinate.latitude)!
                        region.center.longitude = (placemark.location?.coordinate.longitude)!
                        
                        print("lat = \(region.center.latitude)")
                        print("lng = \(region.center.longitude)")
                        
                        self.lat = region.center.latitude
                        self.lng = region.center.longitude
                        
                        region.span = MKCoordinateSpanMake(0.5, 0.5)
                        
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.addAnnotation(placemark)
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "Alert", message: "Location could not be found. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else
                {
                    let alertController = UIAlertController(title: "Alert", message: "Location could not be found. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
            stopProgressView()
            
        }
        else
        {
            let alertController = UIAlertController(title: "Alert", message: "Please enter an address to search.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
     Setting up the progress view that displays a spinner while the serer data is being downloaded.
     The view uses an activity indicator (a spinner) and a simple text to convey the information.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func setProgressView()
    {
        // setting the UI specifications
        var grayColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        var blueColor = UIColor(colorLiteralRed: 45/255, green: 86/255, blue: 105/255, alpha: 1)
        
        
        self.progressView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        self.progressView.backgroundColor = grayColor
        //self.progressView.backgroundColor = UIColor.lightGray
        self.progressView.layer.cornerRadius = 10
        let wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        wait.color = blueColor
        //wait.color = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        wait.hidesWhenStopped = false
        wait.startAnimating()
        
        let message = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        message.text = "Retrieving data..."
        message.textColor = blueColor
        //message.textColor = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        
        self.progressView.addSubview(wait)
        self.progressView.addSubview(message)
        self.progressView.center = self.view.center
        self.progressView.tag = 1000
        
    }
    
    /*
     This method is invoked to remove the progress spinner from the view.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func stopProgressView()
    {
        let subviews = self.view.subviews
        self.progressView.removeFromSuperview()
        //        for subview in subviews
        //        {
        //            if subview.tag == 1000
        //            {
        //                subview.removeFromSuperview()
        //            }
        //        }
    }

}
