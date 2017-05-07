//
//  PanicMapViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 19/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import MessageUI

class PanicMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var smsButton: UIButton!
    
    let BASE_URL: String = "http://35.164.11.87"
    let POLICE_METHOD: String = "/policeinfo/"
    let HOSPITAL_METHOD: String = "/hospitalinfo/"
    
    let locationManager = CLLocationManager()
    var patientLatitude: String?
    var patientLongitude: String?
    var policeStationList: NSMutableArray
    var emergencyServicesList: NSMutableArray
    var selectedEmergencyService: EmergencyService?
    var selectedPoliceStation: PoliceStation?
    
    var fromSegue: Bool
    var ref: FIRDatabaseReference?
    var googleMapsURL: String?
    var emergencyContacts: NSMutableArray
    var previousPatientMarker: CustomPointAnnotation?
    var progressView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        self.fromSegue = false
        self.previousPatientMarker = nil
        self.emergencyServicesList = NSMutableArray()
        self.emergencyContacts = NSMutableArray()
        self.policeStationList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        smsButton.layer.cornerRadius = 10
        setProgressView()
        
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
            readPatientCoordinatesOnce()
            plotPatientLocationOnMap()
            plotGeofenceReferenceLocation()
            readAllEmergencyContacts()
        }
        else        // if data network isn't available show an alert
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callPatient(_ sender: Any) {
        self.ref?.child("patientContacts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                
                let value = current.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                print ("username \(username)")
                if (username == AppDelegate.GlobalVariables.patientID)
                //if (username == "testpatient")
                {
                    if let number = value?["mobileNumber"] as? String {
                        var phNumber: String = number.replacingOccurrences(of: " ", with: "")
                        phNumber = phNumber.replacingOccurrences(of: "-", with: "")
                        guard let number = URL(string: "telprompt://" + phNumber) else { return }
                        UIApplication.shared.open(number, options: [:], completionHandler: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func sendSMSToContacts(_ sender: Any) {
        print("in panic map controller sending sms")
        smsEmergencyContacts()
    }
    
    @IBAction func showMapsRoute(_ sender: Any) {
        performSegue(withIdentifier: "ShowFastestRouteSegue", sender: self)
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

    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        // Zoom to new user location when updated
//        var mapRegion = MKCoordinateRegion()
//        mapRegion.center = mapView.userLocation.coordinate
//        mapRegion.span = mapView.region.span; // Use current 'zoom'
//        mapView.setRegion(mapRegion, animated: true)
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
                if (cpa.imageName == "policestation")
                {
                    print ("showing policestation")
                    patPinAnnotationView.image = #imageLiteral(resourceName: "policeblue")
                    patPinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                else if (cpa.imageName == "firestation")
                {
                    print ("showing firestation")
                    patPinAnnotationView.image = #imageLiteral(resourceName: "firestationorange")
                    patPinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                else if (cpa.imageName == "hospital")
                {
                    print ("showing hospital")
                    patPinAnnotationView.image = #imageLiteral(resourceName: "hospitalred")
                    patPinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                else
                {
                    print ("showing the location annotation")
                    patPinAnnotationView.image = #imageLiteral(resourceName: "home")
                }
            }
            patPinAnnotationView.canShowCallout = true
//            patPinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return patPinAnnotationView
        }
        
        //        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        //        pinAnnotationView.canShowCallout = true
        //        pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        //        return pinAnnotationView
    }

 
    /*
    func getNearestPoliceStationFromGoogleAPI()
    {
        
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.patientLatitude!),\(self.patientLongitude!)&rankby=distance&type=police&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
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
                self.parseMapsJSON(mapsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseMapsJSON(mapsJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: mapsJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let query = result as? NSDictionary
            {
                if let status = query.object(forKey: "status") as? String
                {
                    if (status == "ZERO_RESULTS")
                    {
                        displayAlertMessage(title: "No results", message: "No nearby police stations could be found")
                    }
                    else if (status == "OK")
                    {
                        if let results = query["results"] as? NSArray
                        {
                            var counter: Int = 0
                            for result in results
                            {
                                if (counter < 3)
                                {
                                    if let currentResult: NSDictionary = result as! NSDictionary
                                    {
                                        let newStation: PoliceStation
                                        if let name = currentResult.object(forKey: "name") as? String
                                        {
                                            if let placeID = currentResult.object(forKey: "place_id") as? String
                                            {
                                                var rating: Double? = 0.0
                                                if let policeRating = currentResult.object(forKey: "rating") as? Double
                                                {
                                                    rating = policeRating
                                                }
                                                var imageURL: String? = "nil"
                                                if let photos = currentResult.object(forKey: "photos") as? NSArray
                                                {
                                                    if let firstResult = photos[0] as? NSDictionary
                                                    {
                                                        if let width = firstResult["width"] as? Double
                                                        {
                                                            if let height = firstResult["height"] as? Double
                                                            {
                                                                if let photoRef = firstResult["photo_reference"] as? String
                                                                {
                                                                    imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(Int(width))&maxheight=\(Int(height))&photoreference=\(photoRef)&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
                                                                    print ("image url is \(imageURL)")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let geometry = currentResult["geometry"] as? NSDictionary
                                                {
                                                    if let location = geometry["location"] as? NSDictionary
                                                    {
                                                        let lat = location.object(forKey: "lat") as! Double
                                                        let lng = location.object(forKey: "lng") as! Double
                                                        if (counter == 0)
                                                        {
                                                            newStation = PoliceStation(name: name, placeID: placeID, rating: rating!, imageURL: imageURL!, lat: lat, lng: lng, isClosest: true)
                                                            
                                                            policeStationList.add(newStation)
                                                            
                                                            addPoliceAnnotationOnMap(name: name, lat: lat, lng: lng, isClosest: true)
                                                        }
                                                        else
                                                        {
                                                            newStation = PoliceStation(name: name, placeID: placeID, rating: rating!, imageURL: imageURL!, lat: lat, lng: lng, isClosest: false)
                                                            
                                                            policeStationList.add(newStation)
                                                            
                                                            addPoliceAnnotationOnMap(name: name, lat: lat, lng: lng, isClosest: false)
                                                        }
                                                    }
                                                }
                                            }
                                            counter += 1
                                        
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
*/
    
    func getPoliceInfoFromWebServer()
    {
        
       self.view.addSubview(progressView)
       var requestURL: String?
       requestURL = BASE_URL + POLICE_METHOD + "\(String(describing: patientLatitude!))/\(String(describing: patientLongitude!))"
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
                        let newEmergencyService: EmergencyService
                        if let station = currentResult.object(forKey: "Station") as? String
                        {
                            if let no = currentResult.object(forKey: "No") as? Int
                            {
                                if let street = currentResult.object(forKey: "Street") as? String
                                {
                                    if let type = currentResult.object(forKey: "Type") as? String
                                    {
                                        if let suburb = currentResult.object(forKey: "Suburb") as? String
                                        {
                                           if let postcode = currentResult.object(forKey: "Postcode") as? Int
                                                {
                                                    if let contact = currentResult.object(forKey: "Phone") as? CLong
                                                    {
                                                        if let latitude = currentResult.object(forKey: "Latitude") as? Double
                                                        {
                                                            if let longitude = currentResult.object(forKey: "Longitude") as? Double
                                                            {
                                                                let name: String = "\(station) Police Station"
                                                                let address: String = "\(no) \(street) \(type), \(suburb), VIC - \(postcode)"
                                                                let mapsURL: String = "https://www.google.com/maps/dir/current+location/\(latitude),\(longitude)"
                                                                newEmergencyService = EmergencyService(name: name, type: "Police Station", address: address, phone: String(contact), mapsURL: mapsURL, lat: latitude, lng: longitude)
                                                                self.emergencyServicesList.add(newEmergencyService)
                                                                addPoliceAnnotationOnMap(name: name, lat: latitude, lng: longitude)
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
                getHospitalInfoFromWebServer()
            }
        }
            
        catch{
            print("JSON Serialization error")
        }
    }
    
    func getHospitalInfoFromWebServer()
    {
        var requestURL: String?
        requestURL = BASE_URL + HOSPITAL_METHOD + "\(String(describing: patientLatitude!))/\(String(describing: patientLongitude!))"
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
                self.parseHospitalJSONData(groupsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseHospitalJSONData(groupsJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: groupsJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let results = result as? NSArray
            {
                for groupResult in results
                {
                    if let currentResult: NSDictionary = groupResult as! NSDictionary
                    {
                        let newEmergencyService: EmergencyService
                        if let name = currentResult.object(forKey: "Name") as? String
                        {
                            if let street = currentResult.object(forKey: "Street") as? String
                                {
                                    if let type = currentResult.object(forKey: "Type") as? String
                                    {
                                        if let suburb = currentResult.object(forKey: "Suburb") as? String
                                        {
                                            if let postcode = currentResult.object(forKey: "Postcode") as? Int
                                            {
                                                if let contact = currentResult.object(forKey: "Phone") as? String
                                                {
                                                    if let latitude = currentResult.object(forKey: "Latitude") as? Double
                                                    {
                                                        if let longitude = currentResult.object(forKey: "Longitude") as? Double
                                                        {
                                                            if let no = currentResult.object(forKey: "No") as? String
                                                            {
                                                                let address: String = "\(no) \(street) \(type), \(suburb), VIC - \(postcode)"
                                                                let mapsURL: String = "https://www.google.com/maps/dir/current+location/\(latitude),\(longitude)"
                                                                newEmergencyService = EmergencyService(name: name, type: "Hospital", address: address, phone: contact, mapsURL: mapsURL, lat: latitude, lng: longitude)
                                                                self.emergencyServicesList.add(newEmergencyService)
                                                                addHospitalAnnotationOnMap(name: name, lat: latitude, lng: longitude)
                                                            }
                                                            else if let no = currentResult.object(forKey: "No") as? Int
                                                            {
                                                                let address: String = "\(no) \(street) \(type), \(suburb), VIC - \(postcode)"
                                                                let mapsURL: String = "https://www.google.com/maps/dir/current+location/\(latitude),\(longitude)"
                                                                newEmergencyService = EmergencyService(name: name, type: "Hospital", address: address, phone: contact, mapsURL: mapsURL, lat: latitude, lng: longitude)
                                                                self.emergencyServicesList.add(newEmergencyService)
                                                                addHospitalAnnotationOnMap(name: name, lat: latitude, lng: longitude)
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
                getNearestFireStationFromGoogleAPI()
            }
        }
            
        catch{
            print("JSON Serialization error")
        }
    }


    
    func getNearestFireStationFromGoogleAPI()
    {
        
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.patientLatitude!),\(self.patientLongitude!)&rankby=distance&type=fire_station&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
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
                self.parseFireMapsJSON(fireJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseFireMapsJSON(fireJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: fireJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let query = result as? NSDictionary
            {
                if let status = query.object(forKey: "status") as? String
                {
                    if (status == "ZERO_RESULTS")
                    {
                        displayAlertMessage(title: "No results", message: "No nearby fire stations could be found")
                    }
                    else if (status == "OK")
                    {
                        if let results = query["results"] as? NSArray
                        {
                            DispatchQueue.main.async(){
                                self.stopProgressView()
                            }
                            var counter: Int = 0
                            for result in results
                            {
                                if (counter < 3)
                                {
                                    if let currentResult: NSDictionary = result as! NSDictionary
                                    {
                                        let newEmergencyService: EmergencyService
                                        if let name = currentResult.object(forKey: "name") as? String
                                        {
                                            if let placeID = currentResult.object(forKey: "place_id") as? String
                                            {
                                                var rating: Double? = 0.0
                                                if let policeRating = currentResult.object(forKey: "rating") as? Double
                                                {
                                                    rating = policeRating
                                                }
                                                var imageURL: String? = "nil"
                                                if let photos = currentResult.object(forKey: "photos") as? NSArray
                                                {
                                                    if let firstResult = photos[0] as? NSDictionary
                                                    {
                                                        if let width = firstResult["width"] as? Double
                                                        {
                                                            if let height = firstResult["height"] as? Double
                                                            {
                                                                if let photoRef = firstResult["photo_reference"] as? String
                                                                {
                                                                    imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(Int(width))&maxheight=\(Int(height))&photoreference=\(photoRef)&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
                                                                    print ("image url is \(imageURL)")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let geometry = currentResult["geometry"] as? NSDictionary
                                                {
                                                    if let location = geometry["location"] as? NSDictionary
                                                    {
                                                        let lat = location.object(forKey: "lat") as! Double
                                                        let lng = location.object(forKey: "lng") as! Double
                                                        
                                                        newEmergencyService = EmergencyService(name: name, type: "Fire Station", placeID: placeID, address: "nil", phone: "", mapsURL: "", lat: lat, lng: lng)
                                                        
                                                            emergencyServicesList.add(newEmergencyService)
                                                            
                                                            addFireStationAnnotationOnMap(name: name, lat: lat, lng: lng)
                                                    }
                                                }
                                            }
                                            counter += 1
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            self.mapView.showAnnotations(mapView.annotations, animated: true)
        }
        catch{
            print("JSON Serialization error")
        }
    }

    /*
    func getNearestHospitalsFromGoogleAPI()
    {
        
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.patientLatitude!),\(self.patientLongitude!)&rankby=distance&type=hospital&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
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
                self.parseHopsitalJSON(hospitalJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseHopsitalJSON(hospitalJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: hospitalJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let query = result as? NSDictionary
            {
                if let status = query.object(forKey: "status") as? String
                {
                    if (status == "ZERO_RESULTS")
                    {
                        displayAlertMessage(title: "No results", message: "No nearby police stations could be found")
                    }
                    else if (status == "OK")
                    {
                        if let results = query["results"] as? NSArray
                        {
                            var counter: Int = 0
                            for result in results
                            {
                                if (counter < 3)
                                {
                                    if let currentResult: NSDictionary = result as! NSDictionary
                                    {
                                        let newEmergencyService: EmergencyService
                                        if let name = currentResult.object(forKey: "name") as? String
                                        {
                                            if let placeID = currentResult.object(forKey: "place_id") as? String
                                            {
                                                var rating: Double? = 0.0
                                                if let policeRating = currentResult.object(forKey: "rating") as? Double
                                                {
                                                    rating = policeRating
                                                }
                                                var imageURL: String? = "nil"
                                                if let photos = currentResult.object(forKey: "photos") as? NSArray
                                                {
                                                    if let firstResult = photos[0] as? NSDictionary
                                                    {
                                                        if let width = firstResult["width"] as? Double
                                                        {
                                                            if let height = firstResult["height"] as? Double
                                                            {
                                                                if let photoRef = firstResult["photo_reference"] as? String
                                                                {
                                                                    imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(Int(width))&maxheight=\(Int(height))&photoreference=\(photoRef)&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
                                                                    print ("image url is \(imageURL)")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let geometry = currentResult["geometry"] as? NSDictionary
                                                {
                                                    if let location = geometry["location"] as? NSDictionary
                                                    {
                                                        let lat = location.object(forKey: "lat") as! Double
                                                        let lng = location.object(forKey: "lng") as! Double
                                                        newEmergencyService = EmergencyService(name: name, type: "Hospital", placeID: placeID, address: "nil", phone: "", mapsURL: "", lat: lat, lng: lng)
                                                        
                                                        emergencyServicesList.add(newEmergencyService)
                                                        
                                                        addHospitalAnnotationOnMap(name: name, lat: lat, lng: lng)                                                    }
                                                }
                                            }
                                            counter += 1
                                            
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

 */
    

    func addPoliceAnnotationOnMap(name: String, lat: Double, lng: Double)
    {
        let geoMarker = CustomPointAnnotation()
        geoMarker.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        geoMarker.title = name
        geoMarker.subtitle = "Police Station"
        geoMarker.imageName = "policestation"
        self.mapView.addAnnotation(geoMarker)
        //self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func addFireStationAnnotationOnMap(name: String, lat: Double, lng: Double)
    {
        let geoMarker = CustomPointAnnotation()
        geoMarker.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        geoMarker.title = name
        geoMarker.subtitle = "Fire Station"
        geoMarker.imageName = "firestation"
        self.mapView.addAnnotation(geoMarker)
        //self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func addHospitalAnnotationOnMap(name: String, lat: Double, lng: Double)
    {
        let geoMarker = CustomPointAnnotation()
        geoMarker.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        geoMarker.title = name
        geoMarker.subtitle = "Hospital"
        geoMarker.imageName = "hospital"
        self.mapView.addAnnotation(geoMarker)
        //self.mapView.showAnnotations(mapView.annotations, animated: true)
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

    
    func plotPatientLocationOnMap()
    {
        let patMarker = CustomPointAnnotation()
        self.ref?.child("users").observe(.value, with: { (snapshot) in
            
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
                            
                            self.patientLatitude = patientLat
                            self.patientLongitude = patientLng
                            
                            let patCoordinate = CLLocationCoordinate2D(latitude: Double(self.patientLatitude!)!, longitude: Double(self.patientLongitude!)!)
                            
                            // Zoom to new patient location when updated
                            let region = MKCoordinateRegionMakeWithDistance(patCoordinate, 1000, 1000)
//                            var mapRegion = MKCoordinateRegion()
//                            mapRegion.center = patCoordinate
//                            mapRegion.span = self.mapView.region.span; // Use current 'zoom'
                            self.mapView.setRegion(region, animated: true)
                            
                            //self.getNearestPoliceStationFromGoogleAPI()
                            self.getPoliceInfoFromWebServer()
                        }
                    }
                    
                }
            }})
    }
        
        
    func plotGeofenceReferenceLocation()
    {
        let geoMarker = CustomPointAnnotation()
        self.ref?.child("geofencing").observe(.value, with: { (snapshot) in
            
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
                                        
                                        
                                        self.mapView.removeOverlays(self.mapView.overlays)
                                        self.mapView.addAnnotation(geoMarker)
                                        
                                        // adding a range circle around the annotation (credits given in corresponding function)
                                        let circle = MKCircle(center: geoMarker.coordinate, radius: CLLocationDistance(range) as CLLocationDistance)
                                        self.mapView.add(circle)
                                        
                                        
                                        
                                        var mapRegion = MKCoordinateRegionMakeWithDistance(geoMarker.coordinate, range * 2.5, range * 2.5)
                                        
                                        //self.mapView.setRegion(mapRegion, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowFastestRouteSegue")
        {
            let destinationVC: FastestRouteViewController = segue.destination as! FastestRouteViewController
            self.googleMapsURL = "https://www.google.com/maps/dir/current+location/\((patientLatitude)!),\((patientLongitude)!)"
            destinationVC.googleMapsURL = self.googleMapsURL
        }
        
        if (segue.identifier == "showAnnotationDetails")
        {
            print(selectedEmergencyService?.name)
            let destinationVC: EmergencyServicesDetailViewController = segue.destination as! EmergencyServicesDetailViewController
            destinationVC.currentEmergencyService = selectedEmergencyService
        }

    }
    
    /*
     When the detail disclosure right callout button is clicked, the flows is directed to the details view for the chosen category
     Source: https://www.hackingwithswift.com/example-code/location/how-to-add-a-button-to-an-mkmapview-annotation
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView)
        {
            for service in (emergencyServicesList as NSArray as! [EmergencyService])
            {
                if ((service.name == (view.annotation?.title)!) && (service.type == (view.annotation?.subtitle)!))
                {
                    selectedEmergencyService = service
                }
            }
            self.performSegue(withIdentifier: "showAnnotationDetails", sender: self)
        }
    }
    
    @IBAction func dismissThisViewController(_ sender: Any) {
        
        if (fromSegue) {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
