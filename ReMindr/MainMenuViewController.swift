//
//  MainMenuViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 23/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import LocalAuthentication

class MainMenuViewController: UIViewController {

    @IBOutlet weak var pairingStatusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pairingStatusLabel.layer.cornerRadius = 5
        
//        if (AppDelegate.GlobalVariables.patientID == "Unknown")
//        {
//            self.pairingStatusLabel.text = "Device is not paired. Please go to settings and scan the QR code to pair the device."
//        }
//        else
//        {
//            self.pairingStatusLabel.text = "Device is paired"
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if (AppDelegate.GlobalVariables.patientID == "Unknown")
        {
            self.pairingStatusLabel.text = "Device is not paired. Please go to settings and scan the QR code to pair the device."
            self.pairingStatusLabel.textColor = UIColor.red
        }
        else
        {
            self.pairingStatusLabel.text = "Device is paired"
            let newColor = UIColor(colorLiteralRed: 39/255, green: 174/255, blue: 96/255, alpha: 1)
            self.pairingStatusLabel.textColor = newColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowGeofencingMapSegue")
        {
            
            let destinationVC = segue.destination as! GeofencingViewController
            destinationVC.fromSegue = true
            
        }
        if (segue.identifier == "ShowPanicMapSegue")
        {
            let destinationVC = segue.destination as! PanicMapViewController
            destinationVC.fromSegue = true
        }
    }
    
    @IBAction func showGeofencing(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        

            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { [weak self] (success, error) in
                
                if success{
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "ShowGeofencingMapSegue", sender: self)
                        // let destinationVC = segue.destination as! GeofencingViewController
                        //destinationVC.fromSegue = true
                    }
                }
                else {
                    let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }

            }
    }
    

}
