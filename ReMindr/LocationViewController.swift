//
//  LocationViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 27/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit

protocol addLocationDelegate {
    func addLocation(lat: Double, lng: Double)
}

class LocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{
    
    let locationManager = CLLocationManager()
    var lat : Double?
    var lng : Double?
    var favName: String?
    var delegate: addLocationDelegate?


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
    @IBAction func findCoordinates(_ sender: Any) {
        // remove all annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let address = textAddress.text
        
        if (!((address?.isEmpty)!))
        {
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

        }
        else
        {
            let alertController = UIAlertController(title: "Alert", message: "Please enter an address to search.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
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
    
    /*
     This funtion is invoked when the users confirms the location by clicking on the confirm button.
     The lat and lng values are sent back to the previous view through the delegate.
     */


    
    @IBAction func saveLocation(_ sender: Any) {
        self.delegate!.addLocation(lat: lat!, lng: lng!)
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
