//
//  FavouritesTableViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit

class FavouritesTableViewController: UITableViewController {

    let locationManager = CLLocationManager()
    var favouritesList: NSMutableArray
    var ref: FIRDatabaseReference!
    var selectedIndex: Int!
    var databaseHandle: FIRDatabaseHandle?
    var aDecoder: NSCoder
    
    @IBOutlet weak var noItemsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        
        self.aDecoder = aDecoder
        self.favouritesList = NSMutableArray()
        self.selectedIndex = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // checking if network is available (Reachability class is defined in another file)
        if Reachability.isConnectedToNetwork() == false      // if data network exists
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }

        
        ref = FIRDatabase.database().reference()
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        
        retrieveDataFromFirebase()
        removeAllGeofencing()

        /*
        ref.child("favourites/testpatient").observe(.value, with: { (snapshot) in
            self.favouritesList.removeAllObjects()
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let title = value?["title"] as? String ?? ""
                let desc = value?["desc"] as? String ?? ""
                let imageURL = value?["imageURL"] as? String ?? ""
                let lat = value?["lat"] as? String ?? ""
                let lng = value?["lng"] as? String ?? ""
                let newItem = Favourite(title: title, desc: desc, imageURL: imageURL, lat: lat, lng: lng)
                
                self.favouritesList.add(newItem)
                
                if (lat != "" && lat != "nil")
                {
                    let lat = Double(lat)
                    let lng = Double(lng)
                    let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                    print("lat: \(lat)   lng: \(lng)")
                    
                    let region = (name: newItem.title, coordinate:loc)
                    let notificationRadius = 500
                    let geofence = CLCircularRegion(center: region.coordinate, radius: CLLocationDistance(notificationRadius), identifier: region.name)
                    self.locationManager.startMonitoring(for: geofence)
                    print ("Started monitoring \(region.name)")
                }

            }
            self.tableView.reloadData()
            if self.favouritesList.count == 0
            {
                self.noItemsLabel.text = "No favourites to display"
            }
            else
            {
                self.noItemsLabel.text = ""
            }
            
        })
 */

    }
    
    
    func retrieveDataFromFirebase()
    {
        
        // Retrieve the list of favourites and listen for changes
        ref.child("favourites/testpatient").observeSingleEvent(of: .value, with: {(snapshot) in
            
            self.favouritesList.removeAllObjects()
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            /*
            if let dictionary = snapshot.value as? [String: Any] {
                let currentFav = Favourite()
                currentFav.setValuesForKeys(dictionary)
                self.favouritesList.add(currentFav)
             
                
            }
            
 */
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let title = value?["title"] as? String ?? ""
                let desc = value?["desc"] as? String ?? ""
                let status = value?["status"] as? String ?? ""
                let imageURL = value?["imageURL"] as? String ?? ""
                let lat = value?["lat"] as? String ?? ""
                let lng = value?["lng"] as? String ?? ""
                let newItem = Favourite(title: title, desc: desc, status: status, imageURL: imageURL, lat: lat, lng: lng)
                
//                let value = current.value as! [String : Any]
//                let newItem = Favourite()
//                newItem.setValuesForKeys(value)
//                
//                let lat = newItem.lat!
//                let lng = newItem.lng!
                
                self.favouritesList.add(newItem)
                
                /* not monitoring regions for caregiver
 
                if (lat != "" && lat != "nil")
                {
                    let lat = Double(lat)
                    let lng = Double(lng)
                    let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                    print("lat: \(lat)   lng: \(lng)")
                    
                    let region = (name: newItem.title, coordinate:loc)
                    let notificationRadius = 500
                    let geofence = CLCircularRegion(center: region.coordinate, radius: CLLocationDistance(notificationRadius), identifier: region.name!)
                    self.locationManager.startMonitoring(for: geofence)
                    //print ("Started monitoring \(region.name)")
                }
 
                */
                
            }
            self.tableView.reloadData()
            if self.favouritesList.count == 0
            {
                self.noItemsLabel.text = "No favourites to display"
            }
            else
            {
                self.noItemsLabel.text = ""
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Retrieve the list of favourites and listen for changes
        retrieveDataFromFirebase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favouritesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteCell", for: indexPath) as! FavouriteCell
        
        let f: Favourite = self.favouritesList[indexPath.row] as! Favourite
        cell.labelTitle.text = f.title
        if (f.status == "Good")
        {
            cell.statusImage.image = #imageLiteral(resourceName: "do")
        }
        else
        {
            cell.statusImage.image = #imageLiteral(resourceName: "don't")
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this item?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                
                /*
                // delete geofencing for the favourite
                let mapViewClass: MapViewController
                mapViewClass = MapViewController(coder: self.aDecoder)!
                mapViewClass.removeGeofencingForFavourite(favourite: self.favouritesList.object(at: indexPath.row) as! Favourite)
                
 */
                
                
                self.ref.child("favourites/testpatient").child(((self.favouritesList.object(at: indexPath.row)) as! Favourite).title!).removeValue()
                
                self.retrieveDataFromFirebase()
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Delete cancelled")
            }))
            
            present(deleteAlert, animated: true, completion: nil)

        }
    }
    
    func removeAllGeofencing()
    {
        for current in favouritesList
        {
            let currentFav = current as! Favourite
            let lat = currentFav.lat
            let lng = currentFav.lng
            if (lat != "" && lat != "nil")
            {
                let lat = Double(lat!)
                let lng = Double(lng!)
                let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                //print("lat: \(lat)   lng: \(lng)")
                
                let region = (name: currentFav.title, coordinate:loc)
                let notificationRadius = 500
                let geofence = CLCircularRegion(center: region.coordinate, radius: CLLocationDistance(notificationRadius), identifier: region.name!)
                self.locationManager.stopMonitoring(for: geofence)
               // print ("Stop monitoring \(region.name)")
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ViewFavouriteSegue")
        {
            let destinationVC: ViewFavouriteViewController = segue.destination as! ViewFavouriteViewController
            self.selectedIndex = self.tableView.indexPathForSelectedRow!.row
            destinationVC.currentFavourite = self.favouritesList.object(at: self.selectedIndex) as? Favourite
            //destinationVC.delegate = self
            
        }
        if (segue.identifier == "ViewMapSegue")
        {
            let destinationVC: MapViewController = segue.destination as! MapViewController
            destinationVC.favouriteList = self.favouritesList
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Only show user location in MapView if user has authorized location tracking
        //mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    
    /*
    /*
     To notify a user when a category region is entered
     Source: Tutorials by Matthew Kairys
     */
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
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
        } else {
            // App is inactive, show a notification
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = message
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    /*
     To notify a user when a category region is exited
     Source: Tutorials by Matthew Kairys
     */
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region \(region.identifier)")
        // Notify the user when they have entered a region
        let title = "ReMindr"
        let message = "You are leaving '\(region.identifier)' region."
        
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
            if #available(iOS 8.2, *) {
                notification.alertTitle = title
            } else {
                // Fallback on earlier versions
            }
            notification.alertBody = message
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        
    }
 
 */
}
