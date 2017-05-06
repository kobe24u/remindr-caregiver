//
//  SettingsTableViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 5/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelContactNumber: UILabel!

    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textContactNumber: UITextField!
    
    @IBOutlet weak var profileBackImageView: UIImageView!
    @IBOutlet var profileView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var ref: FIRDatabaseReference?
    var patientName: String?
    var patientContact: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        self.profileView.layer.cornerRadius = 5
        self.profileBackImageView.layer.cornerRadius = 20
        self.profileBackImageView.clipsToBounds = true
        
        self.textName.delegate = self
        self.textContactNumber.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        profileView.addGestureRecognizer(tap)
    
        retrieveDataFromFirebase()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textName.endEditing(true)
        self.textContactNumber.endEditing(true)
        return true
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
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! SettingsTableViewCell
            //set the data here
            cell.accessoryType = UITableViewCellAccessoryType.detailButton
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! SettingsTableViewCell
            //set the data here
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutUsCell", for: indexPath) as! SettingsTableViewCell
            //set the data here
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QRCodeCell", for: indexPath) as! SettingsTableViewCell
            //set the data here
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0)
        {
            animateIn()
        }
    }

    func retrieveDataFromFirebase()
    {
        ref?.child("patientContacts").child(AppDelegate.GlobalVariables.patientID).observe(.value, with: {(snapshot) in
        //ref?.child("patientContacts").child("testpatient").observe(.value, with: {(snapshot) in
            
            if let name = snapshot.childSnapshot(forPath: "name").value as? String {
                self.patientName = name
            }
            if let number = snapshot.childSnapshot(forPath: "mobileNumber").value as? String {
                self.patientContact = number
            }
          self.assignLabels()
          self.assignTextFields()
        })
    }

    func animateIn()
    {
        self.view.addSubview(profileView)
        profileView.center = self.view.center
        profileView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        profileView.alpha = 0
        
        self.labelName.isHidden = false
        self.labelContactNumber.isHidden = false
        self.textName.isHidden = true
        self.textContactNumber.isHidden = true
        
        self.doneButton.isHidden = false
        self.cancelButton.isHidden = true
        self.saveButton.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.profileView.alpha = 1
            self.profileView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.profileView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.profileView.alpha = 0
        }, completion: {(success: Bool) in
            self.profileView.removeFromSuperview()
        })

        self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
    }

    @IBAction func doneWithProfileView(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func editProfileDetails(_ sender: Any) {
        
        self.labelName.isHidden = true
        self.labelContactNumber.isHidden = true
        self.textName.isHidden = false
        self.textContactNumber.isHidden = false
        self.doneButton.isHidden = true
        self.saveButton.isHidden = false
        self.cancelButton.isHidden = false
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func saveProfileDetails(_ sender: Any) {
        
        var textName: String?
        var textMobile: String?
        
        textName = self.textName.text
        textMobile = self.textContactNumber.text
        
        print ("name and contact \(textName) \(textMobile)")
        
        if ((textName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (textMobile?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!)
        {
            displayAlertMessage(title: "Alert", message: "Name and mobile number are mandatory")
        }
        else
        {
            if (textMobile?.characters.count != 10)
            {
                displayAlertMessage(title: "Invalid number", message: "Please enter a 10 digit number (eg. 0401234532")
            }
            else
            {
                let username: String = AppDelegate.GlobalVariables.patientID
                //let username: String = "testpatient"
                let values: [String: Any]
                values = ["name": textName ?? "nil", "mobileNumber": textMobile ?? "nil", "username": username]
                ref?.child("patientContacts").child(username).setValue(values)
                animateOut()
            }
        }
    }
    
    @IBAction func cancelProfileDetails(_ sender: Any) {
        self.textName.text = labelName.text
        self.textContactNumber.text = labelContactNumber.text
        animateOut()
    }
    
    
    func assignLabels()
    {
        self.labelName.text = patientName
        self.labelContactNumber.text = patientContact
    }
    
    func assignTextFields()
    {
        self.textName.text = patientName
        self.textContactNumber.text = patientContact
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
