//
//  GeofencingViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import MessageUI

class GeofencingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var manualDismissButton: UIBarButtonItem!
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var smsEmergencyButton: UIButton!
    
    //var currentCategory: Category?
    var emergencyContacts: NSMutableArray
    var patientLatitude: String?
    var patientLongitude: String?
    var selectedPosition: Int?
    let locationManager = CLLocationManager()
    var ref: FIRDatabaseReference!
    var fromSegue: Bool
    
    var midLatitude: Double?
    var midLongitude: Double?
    var previousPatientMarker: CustomPointAnnotation?
    var previousGeofenceMarker: CustomPointAnnotation?
    
    required init?(coder aDecoder: NSCoder)
    {
        emergencyContacts = NSMutableArray()
        fromSegue = false
        previousPatientMarker = nil
        previousGeofenceMarker = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        smsEmergencyButton.layer.cornerRadius = 10
//        if let sender = sender {
//                manualDismissButton.isEnabled = false
//                manualDismissButton.tintColor = UIColor.clear
//        }
        

        
        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        
        //mapView.showsUserLocation = true
        
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
        
        
    }
    
    func promptMessage(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readPatientCoordinatesOnce()
        plotGeofenceReferenceLocation()
        plotPatientLocationOnMap()
        readAllEmergencyContacts()
        
        if (AppDelegate.GlobalVariables.patientID == "Unknown")
        {
            promptMessage(title: "Device Not Paired", message: "Please pair the device to your loved one's device to view their location")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callPatient(_ sender: Any) {
        
        self.ref.child("patientContacts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                
                let value = current.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                print ("username \(username)")
                if (username == AppDelegate.GlobalVariables.patientID)
                //if (username == "testpatient")
                {
                    if let number = value?["mobileNumber"] as? String {
                        guard let number = URL(string: "telprompt://" + number) else { return }
                        UIApplication.shared.open(number, options: [:], completionHandler: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func smsEmergencyContacts(_ sender: Any) {
        smsEmergencyContacts()
    }
    
    func smsEmergencyContacts()
    {
        var name: String = AppDelegate.GlobalVariables.patientName
        var mobileNumber: String = AppDelegate.GlobalVariables.patientNumber
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "\(name) needs your help. \(name)'s mobile number is \(mobileNumber). Last known location can be seen here: https://www.google.com/maps/dir/current+location/\((patientLatitude)!),\((patientLongitude)!)"
            //            controller.recipients = ["0401289325"]
            controller.recipients = emergencyContacts as! [String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func readAllEmergencyContacts()
    {
        ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).observe(.value, with: {(snapshot) in
            //ref?.child("emergencyContacts/testpatient").observe(.value, with: {(snapshot) in
            
            self.emergencyContacts.removeAllObjects()
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let name = value?["name"] as? String ?? ""
                let mobile = value?["mobile"] as? String ?? ""
                let newItem: EmergencyContact = EmergencyContact(name: name, mobile: mobile)
                
                self.emergencyContacts.add(mobile)
            }
        })
        
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
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
            circle.fillColor = UIColor.orange.withAlphaComponent(0.2)
            circle.lineWidth = 1
            return circle
        }
        else
        {
            return nil
        }
    }
    
//    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        mapView.showAnnotations(mapView.annotations, animated: true)
//    }
    
    /*
     A function to perform an action if the user clicks on an annotation. A detail discloure button is shown to the user.
     Source: https://www.hackingwithswift.com/example-code/location/how-to-add-a-button-to-an-mkmapview-annotation
     
     */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        else
        {
            let cpa = annotation as! CustomPointAnnotation
            let patPinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            print("cpa.imageName : \(cpa.imageName!)")
            patPinAnnotationView.canShowCallout = true
            
            if (cpa.title == "Patient Location")
            {
                print ("showing the patient annotation")
                patPinAnnotationView.image = #imageLiteral(resourceName: "patient")
            }
            else
            {
                print ("showing the location annotation")
                patPinAnnotationView.image = #imageLiteral(resourceName: "home")
            }
            
            return patPinAnnotationView
        }
        
//        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
//        pinAnnotationView.canShowCallout = true
//        pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        return pinAnnotationView
    }
    
    /*
 
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
    
 */
    
    @IBAction func goToGeoSettings(_ sender: Any) {
        if (AppDelegate.GlobalVariables.patientID != "Unknown")
        {
            performSegue(withIdentifier: "ShowGeofencingSettingsSegue", sender: self)
        }
        else
        {
            promptMessage(title: "Device Not Paired", message: "Please pair the device to access geofencing settings")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "ShowGeofencingSettingsSegue")
        {
                let destinationVC: GeoSettingsViewController = segue.destination as! GeoSettingsViewController
        }
    }
    
    func plotPatientLocationOnMap()
    {
        
        let patMarker = CustomPointAnnotation()
        self.ref.child("users").observe(.value, with: { (snapshot) in
            
            if (self.previousPatientMarker != nil)
            {
                self.mapView.removeAnnotation(self.previousPatientMarker!)
            }

            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                
                let value = current.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                print ("username \(username)")
                if (username == AppDelegate.GlobalVariables.patientID)
                //if (username == "testpatient")
                {
                    if let patientLat = value?["patLat"] as? String {
                        if let patientLng = value?["patLng"] as? String {
                            
                            self.patientLatitude = patientLat
                            self.patientLongitude = patientLng
                            print ("lat and lng for patient \(patientLat) \(patientLng)")
                            patMarker.coordinate = CLLocationCoordinate2D(latitude: Double(patientLat)!, longitude: Double(patientLng)!)
                            patMarker.title = "Patient Location"
                            patMarker.subtitle = "My patient is here"
                            patMarker.imageName = "patient"
                            
                            self.previousPatientMarker = patMarker
                            self.mapView.addAnnotation(patMarker)
                            //self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                        }
                    }
                    
                }
            }
        })
    }


    func plotGeofenceReferenceLocation()
    {
        let geoMarker = CustomPointAnnotation()
        self.ref.child("geofencing").observe(.value, with: { (snapshot) in
        
            if (self.previousGeofenceMarker != nil)
            {
                self.mapView.removeAnnotation(self.previousGeofenceMarker!)
            }
            
            if let current = snapshot.childSnapshot(forPath: AppDelegate.GlobalVariables.patientID) as? FIRDataSnapshot
            //if let current = snapshot.childSnapshot(forPath: "testpatient") as? FIRDataSnapshot
            {
                let value = current.value as? NSDictionary
                if let location = value?["locationName"] as? String
                {
                    print ("location name is \(location)")
                    if let locationLat = value?["locLat"] as? String {
                        if let locationLng = value?["locLng"] as? String {
                            print ("lat and lng for location \(locationLat) \(locationLng)")
                            if let range = value?["range"] as? Double {
                                print("radius is \(range)")
                                if let enabled = value?["enabled"] as? String {
                                    print("enabled is \(enabled)")
                                    if (enabled == "true")
                                    {
                                        geoMarker.coordinate = CLLocationCoordinate2D(latitude: Double(locationLat)!, longitude: Double(locationLng)!)
                                    geoMarker.title = location
                                    geoMarker.subtitle = "Radius: \(range)m"
                                    geoMarker.imageName = "home"
                                    
                                    self.previousGeofenceMarker = geoMarker
                                    self.mapView.removeOverlays(self.mapView.overlays)
//                                    self.mapView.removeAnnotations(self.mapView.annotations)
//                                    self.plotPatientLocationOnMap()
                                    self.mapView.addAnnotation(geoMarker)
                                    
                                    // adding a range circle around the annotation (credits given in corresponding function)
                                    let circle = MKCircle(center: geoMarker.coordinate, radius: CLLocationDistance(range) as CLLocationDistance)
                                    self.mapView.add(circle)
                                        

                                    
                                    var mapRegion = MKCoordinateRegionMakeWithDistance(geoMarker.coordinate, range * 2.5, range * 2.5)
                                    
                                    //self.mapView.setRegion(mapRegion, animated: true)
                                    //self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            
            }
        })
    }
    
    func readPatientCoordinatesOnce()
    {
        self.ref?.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                print ("username \(username)")
                if (username == AppDelegate.GlobalVariables.patientID)
                //if (username == "testpatient")
                {
                    if let patientLat = value?["patLat"] as? String {
                        if let patientLng = value?["patLng"] as? String {

                            let patCoordinate = CLLocationCoordinate2D(latitude: Double(patientLat)!, longitude: Double(patientLng)!)
                            
                            // Zoom to new patient location when updated
                            let region = MKCoordinateRegionMakeWithDistance(patCoordinate, 500, 500)
                            //                            var mapRegion = MKCoordinateRegion()
                            //                            mapRegion.center = patCoordinate
                            //                            mapRegion.span = self.mapView.region.span; // Use current 'zoom'
                            self.mapView.setRegion(region, animated: true)
                        }
                    }
                    
                }
            }})
    }
    
    @IBAction func dismissThisViewController(_ sender: Any) {

        if (fromSegue) {
//            self.navigationController?.popViewController(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
