//
//  PoliceStationDetailsViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 20/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class PoliceStationDetailsViewController: UIViewController {

    @IBOutlet weak var labelStationName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var imageViewPolice: UIImageView!
    @IBOutlet weak var labelPhone: UILabel!
    
    
    var currentPoliceStation: PoliceStation?
    var urlToOpen: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() == false      // if data network exists
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else
        {
            getPoliceStationDetailsFromGoogleAPI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func showStationOnGoogleMapsAgain(_ sender: Any) {
        self.urlToOpen = currentPoliceStation?.mapsURL
        performSegue(withIdentifier: "showPoliceWebDetailsSegue", sender: self)
    }
    
    @IBAction func showStationWebsiteAgain(_ sender: Any) {
        self.urlToOpen = currentPoliceStation?.website
        performSegue(withIdentifier: "showPoliceWebDetailsSegue", sender: self)
    }
    
    @IBAction func showStationOnGoogleMaps(_ sender: Any) {
        self.urlToOpen = currentPoliceStation?.mapsURL
        performSegue(withIdentifier: "showPoliceWebDetailsSegue", sender: self)
    }
    
    @IBAction func showStationWebsite(_ sender: Any) {
        self.urlToOpen = currentPoliceStation?.website
        performSegue(withIdentifier: "showPoliceWebDetailsSegue", sender: self)
    }
    
    
    func getPoliceStationDetailsFromGoogleAPI()
    {
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\((currentPoliceStation?.placeID!)!)&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
        print ("request url is \(requestURL)")
        
        let url: NSURL = NSURL(string: requestURL!)!
        let task = URLSession.shared.dataTask(with: url as URL){
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage(title: "Connection Failed", message: "Failed to retrieve data from the server")
            }
            else
            {
                self.parsePoliceJSON(mapsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parsePoliceJSON(mapsJSON:NSData){
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
                        if let results = query.object(forKey: "result") as? NSDictionary
                        {
                            if let address = results.object(forKey: "formatted_address") as? String
                            {
                                if let phone = results.object(forKey: "international_phone_number") as? String
                                {
                                    if let mapsURL = results.object(forKey: "url") as? String
                                    {
                                        if let website = results.object(forKey: "website") as? String
                                        {
                                            currentPoliceStation?.address = address
                                            currentPoliceStation?.mapsURL = mapsURL
                                            currentPoliceStation?.phone = phone
                                            currentPoliceStation?.website = website
                                            DispatchQueue.main.async(){
                                                self.assignLabels()
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

    func assignLabels()
    {
        self.labelStationName.text = currentPoliceStation?.name
        self.labelAddress.text = currentPoliceStation?.address
        if (currentPoliceStation?.rating != 0.0)
        {
            self.labelRating.text = (String(describing: (currentPoliceStation?.rating!)!))
        }
        else
        {
            self.labelRating.text = "-"
        }
        self.labelPhone.text = currentPoliceStation?.phone
        let url = URL(string: (currentPoliceStation?.imageURL!)!)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil
            {
                print (error)
                return
            }
            
            DispatchQueue.main.async {
                self.imageViewPolice.image = UIImage(data: data!)
            }
            
        }).resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPoliceWebDetailsSegue")
        {
            let destinationVC: PoliceWebDetailsViewController = segue.destination as! PoliceWebDetailsViewController
            destinationVC.googleURL = urlToOpen!
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
