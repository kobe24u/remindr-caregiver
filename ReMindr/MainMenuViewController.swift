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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowGeofencingMapSegue")
        {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            let destinationVC = segue.destination as! GeofencingViewController
                            destinationVC.fromSegue = true
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                        }
                    }
                }
            } else {
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { [weak self] (success, error) in
                    
                    guard success else {
                        DispatchQueue.main.async() {
                            // show something here to block the user from continuing
                            let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(ac, animated: true)
                        }
                        
                        return
                    }
                    
                    DispatchQueue.main.async() {
                        // do something here to continue loading your app, e.g. call a delegate method
                        let destinationVC = segue.destination as! GeofencingViewController
                        destinationVC.fromSegue = true
                    }
                }
                
                
//                let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default))
//                present(ac, animated: true)
            }
            
        }
        if (segue.identifier == "ShowPanicMapSegue")
        {
            let destinationVC = segue.destination as! PanicMapViewController
            destinationVC.fromSegue = true
        }
    }
    
    

}
