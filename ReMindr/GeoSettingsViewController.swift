//
//  GeoSettingsViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase

class GeoSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, geofenceLocationDelegate, UITextFieldDelegate {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var rangePicker: UIPickerView!
    @IBOutlet weak var textLocationName: UITextField!
    @IBOutlet weak var textLocationConfirmation: UILabel!
    @IBOutlet weak var assignLocationButton: UIButton!
    
    var locationLat: Double?
    var locationLng: Double?
    var ref: FIRDatabaseReference!
    
    var notificationRange: Double
    // the values to be held by the pickerView (distance shown in metres)
    let rangePickerValues = ["200m", "300m", "500m", "750m", "1000m"]

    required init?(coder aDecoder: NSCoder) {
        notificationRange = 100
        locationLat = nil
        locationLng = nil
        ref = FIRDatabase.database().reference()
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.assignLocationButton.layer.cornerRadius = 5
        self.textLocationName.delegate = self
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
        rangePicker.dataSource = self
        rangePicker.delegate = self
        assignLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func saveGeofencingSettings(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let locationName: String?
        let notificationOn: String?
        
        locationName = textLocationName.text
        if (locationName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!
        {
            displayAlertMessage(title: "Alert", message: "Location name is mandatory")
        }
        else if (locationLat == nil)
        {
            displayAlertMessage(title: "Alert", message: "Please assign a location")
        }
        else
        {
            if (notificationSwitch.isOn)
            {
                notificationOn = "true"
            }
            else
            {
                notificationOn = "false"
            }
            
            let values: [String: Any]
            values = ["locationName": locationName ?? "Home", "enabled": notificationOn ?? "true", "range": notificationRange, "locLat": "\(locationLat!)", "locLng": "\(locationLng!)", "violated": "false" ]
            
            //TODO: Add this value to geofencing settings for the given patient
            self.ref.child("geofencing/testpatient").setValue(values)
            self.navigationController?.popViewController(animated: true)
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC: AddLocationViewController = segue.destination as! AddLocationViewController
        destinationVC.delegate = self
    }
    
    // configuring the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return rangePickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rangePickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(row)
        {
        case 0: self.notificationRange = 200
        case 1: self.notificationRange = 300
        case 2: self.notificationRange = 500
        case 3: self.notificationRange = 750
        case 4: self.notificationRange = 1000
        default: self.notificationRange = 200
        }
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func addGeofenceLocation(locLat: Double, locLng: Double) {
        self.locationLat = locLat
        self.locationLng = locLng
        textLocationConfirmation.text = "Location has been assigned"
    }
    
    func assignLabels ()
    {
        textLocationConfirmation.text = ""
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
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textLocationName.endEditing(true)
        return true
    }

}
