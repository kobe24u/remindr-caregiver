//
//  SupportGroupsMapViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit

class SupportGroupsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var BASE_URL: String = "http://35.161.212.185"
    var SUPPORT_METHOD: String = "/communitysupportinfo/"
    
    let locationManager = CLLocationManager()
    var supportGroupList: NSMutableArray
    var selectedSupportGroup: SupportGroup?
    var myLatitude: Double
    var myLongitude: Double
    
    required init?(coder aDecoder: NSCoder) {
        myLatitude = -37.8
        myLongitude = 145.07
        supportGroupList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        locationManager.delegate = self
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        
        // checking if network is available (Reachability class is defined in another file)
        if Reachability.isConnectedToNetwork() == true      // if data network exists
        {
            print("Internet connection OK")
            readAllSupportGroupInfo()
//            readPatientCoordinatesOnce()
//            plotPatientLocationOnMap()
//            plotGeofenceReferenceLocation()
//            readAllEmergencyContacts()
        }
        else        // if data network isn't available show an alert
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //        // Zoom to new user location when updated
        //        var mapRegion = MKCoordinateRegion()
        //        mapRegion.center = mapView.userLocation.coordinate
        //        mapRegion.span = mapView.region.span; // Use current 'zoom'
        //        mapView.setRegion(mapRegion, animated: true)
        self.myLatitude = userLocation.coordinate.latitude
        self.myLongitude = userLocation.coordinate.longitude
    }
    
    func readAllSupportGroupInfo()
    {
        var requestURL: String?
        requestURL = BASE_URL + SUPPORT_METHOD + "\(myLatitude)/\(myLongitude)"
        print ("request url is \(requestURL)")
        
        var url: NSURL = NSURL(string: requestURL!)!
        let task = URLSession.shared.dataTask(with: url as URL){
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage(title: "Connection Failed", message: "Failed to retrieve data from the server")
            }
            else
            {
                self.parseJSONData(groupsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseJSONData(groupsJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: groupsJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let results = result as? NSArray
            {
                for groupResult in results
                {
                    if let currentResult: NSDictionary = groupResult as! NSDictionary
                    {
                        let newGroup: SupportGroup
                        if let name = currentResult.object(forKey: "Name") as? String
                        {
                            if let address = currentResult.object(forKey: "Address") as? String
                            {
                                if let suburb = currentResult.object(forKey: "Suburb") as? String
                                {
                                    if let state = currentResult.object(forKey: "State") as? String
                                    {
                                        if let postcode = currentResult.object(forKey: "Postcode") as? Int
                                        {
                                            if let contact = currentResult.object(forKey: "Phone") as? String
                                            {
                                                if let email = currentResult.object(forKey: "Email") as? String
                                                {
                                                    if let website = currentResult.object(forKey: "Website") as? String
                                                    {
                                                        if let latitude = currentResult.object(forKey: "Latitude") as? Double
                                                        {
                                                            if let longitude = currentResult.object(forKey: "Longitude") as? Double
                                                            {
                                                                let mapsURL: String
                                                                mapsURL = "https://www.google.com/maps/dir/current+location/\(latitude),\(longitude)"
                                                                newGroup = SupportGroup(name: name, address: address, suburb: suburb, state: state, postcode: postcode, contact: contact, email: email, website: website, mapsURL: mapsURL, latitude: latitude, longitude: longitude)
                                                                self.supportGroupList.add(newGroup)
                                                                addSupportGroupOnMap(name: name, suburb: suburb, lat: latitude, lng: longitude)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
            
        catch{
            print("JSON Serialization error")
        }
    }

    func addSupportGroupOnMap(name: String, suburb: String, lat: Double, lng: Double)
    {
        let geoMarker = CustomPointAnnotation()
        geoMarker.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        geoMarker.title = name
        geoMarker.subtitle = suburb
        geoMarker.imageName = "supportgroupicon"
        self.mapView.addAnnotation(geoMarker)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Only show user location in MapView if user has authorized location tracking
        mapView.showsUserLocation = (status == .authorizedAlways)
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
        else
        {
            let cpa = annotation as! CustomPointAnnotation
            let patPinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            print("cpa.imageName : \(cpa.imageName!)")
            patPinAnnotationView.canShowCallout = true
            patPinAnnotationView.image = #imageLiteral(resourceName: "supportgroupicon")
            patPinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            self.mapView.showAnnotations(mapView.annotations, animated: true)
            return patPinAnnotationView
        }
        
        /*
        //        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        //        pinAnnotationView.canShowCallout = true
        //        pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
 
        //        return pinAnnotationView
 
    */
    }

    /*
     When the detail disclosure right callout button is clicked, the flows is directed to the details view for the chosen category
     Source: https://www.hackingwithswift.com/example-code/location/how-to-add-a-button-to-an-mkmapview-annotation
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView)
        {
            for supportGroup in (supportGroupList as NSArray as! [SupportGroup])
            {
                if ((supportGroup.name == (view.annotation?.title)!) && (supportGroup.suburb == (view.annotation?.subtitle)!))
                {
                    selectedSupportGroup = supportGroup
                }
            }
            self.performSegue(withIdentifier: "ShowSupportAnnotationDetails", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SearchForSupportSegue")
        {
            let destinationVC: SupportGroupSearchViewController = segue.destination as! SupportGroupSearchViewController
        }
        if (segue.identifier == "ShowSupportAnnotationDetails")
        {
            print(selectedSupportGroup?.name)
            let destinationVC: SupportGroupDetailsViewController = segue.destination as! SupportGroupDetailsViewController
            destinationVC.currentSupportGroup = selectedSupportGroup
        }
    }
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
