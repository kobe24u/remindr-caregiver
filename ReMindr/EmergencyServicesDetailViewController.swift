//
//  EmergencyServicesDetailViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 4/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class EmergencyServicesDetailViewController: UIViewController {

    var currentEmergencyService: EmergencyService?
    
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelServiceContact: UILabel!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var additionalDetailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        additionalDetailsView.isHidden = true
        
        self.labelAddress.lineBreakMode = .byWordWrapping
        self.labelAddress.numberOfLines = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EmergencyServicesDetailViewController.callService2))
        self.labelServiceContact.isUserInteractionEnabled = true
        self.labelServiceContact.addGestureRecognizer(tap)
        

        
        if (currentEmergencyService?.type != "Police Station")
        {
            if Reachability.isConnectedToNetwork() == false      // if data network exists
            {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else
            {
                getEmergencyServiceDetailsFromGoogleAPI()
            }
        }
        else
        {
            assignLabels()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func callEmergencyService()
    {
        var phNumber: String?
        phNumber = currentEmergencyService?.phone
        phNumber = phNumber?.replacingOccurrences(of: " ", with: "")
        guard let number = URL(string: "telprompt://" + phNumber!) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }


    @IBAction func callService1(_ sender: Any) {
        callEmergencyService()
    }
    
    func callService2()
    {
        callEmergencyService()
    }
    
    @IBAction func navigateToMaps1(_ sender: Any) {
        performSegue(withIdentifier: "showServiceWebDetailsSegue", sender: self)
    }
    
    @IBAction func navigateToMaps2(_ sender: Any) {
        performSegue(withIdentifier: "showServiceWebDetailsSegue", sender: self)
    }
    
    func getEmergencyServiceDetailsFromGoogleAPI()
    {
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\((currentEmergencyService?.placeID!)!)&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
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
                self.parseEmergencyJSON(emergencyJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseEmergencyJSON(emergencyJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: emergencyJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
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
                                            currentEmergencyService?.address = address
                                            currentEmergencyService?.mapsURL = mapsURL
                                            currentEmergencyService?.phone = phone
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
        additionalDetailsView.isHidden = false
        self.labelName.text = currentEmergencyService?.name
        self.labelAddress.text = currentEmergencyService?.address
        self.labelServiceContact.text = currentEmergencyService?.phone
        
        if (currentEmergencyService?.type == "Fire Station")
        {
            self.serviceImageView.image = #imageLiteral(resourceName: "firestationorange")
        }
        else if (currentEmergencyService?.type == "Hospital")
        {
            self.serviceImageView.image = #imageLiteral(resourceName: "hospitalred")
        }
        else
        {
            self.serviceImageView.image = #imageLiteral(resourceName: "policeblue")
        }
        
        
//        let url = URL(string: (currentPoliceStation?.imageURL!)!)
//        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//            
//            if error != nil
//            {
//                print (error)
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self.imageViewPolice.image = UIImage(data: data!)
//            }
//            
//        }).resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showServiceWebDetailsSegue")
        {
            let destinationVC: PoliceWebDetailsViewController = segue.destination as! PoliceWebDetailsViewController
            destinationVC.googleURL = currentEmergencyService?.mapsURL!
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
