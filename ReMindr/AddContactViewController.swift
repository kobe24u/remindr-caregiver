//
//  AddContactViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 18/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase

class AddContactViewController: UIViewController {
    
    var ref: FIRDatabaseReference?
    
    @IBOutlet weak var contactNameText: UITextField!
    @IBOutlet weak var contactNumberText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addEmergencyContact(_ sender: Any) {
        
        var textName: String?
        var textMobile: String?
        
        textName = contactNameText.text
        textMobile = contactNumberText.text
        
        if ((textName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (textMobile?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!)
        {
            displayAlertMessage(title: "Alert", message: "Title and Description are mandatory")
        }
        else
        {
            let values: [String: Any]
            values = ["name": textName ?? "nil", "mobile": textMobile ?? "nil"]
            //ref?.child("emergencyContacts/testpatient").child(textMobile!).setValue(values)
            self.view.removeFromSuperview()
        }
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
    
}
