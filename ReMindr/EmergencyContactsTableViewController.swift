//
//  EmergencyContactsTableViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 18/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import ContactsUI

class EmergencyContactsTableViewController: UITableViewController, UITextFieldDelegate, CNContactPickerDelegate {

    @IBOutlet weak var saveContactButton: UIButton!
    @IBOutlet var addContactView: UIView!
    @IBOutlet weak var textContactName: UITextField!
    @IBOutlet weak var textContactNumber: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var ref: FIRDatabaseReference?
    var emergencyList: NSMutableArray
    var selectedContact: String?
    var isFromPhonebook: Bool = false
    var hasMobile: Bool = true
    
    @IBOutlet weak var noContactsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        selectedContact = nil
        emergencyList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addContactView.layer.cornerRadius = 5
        self.saveContactButton.layer.cornerRadius = 5
        self.addContactView.layer.cornerRadius = 10
        self.backgroundImageView.layer.cornerRadius = 10
        self.backgroundImageView.clipsToBounds = true
        
        self.textContactName.delegate = self
        self.textContactNumber.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EmergencyContactsTableViewController.dismissKeyboard))
        self.addContactView.addGestureRecognizer(tap)
        self.backgroundImageView.addGestureRecognizer(tap)
        
        ref = FIRDatabase.database().reference()
        self.noContactsLabel.text = ""
        
    }

    override func viewWillAppear(_ animated: Bool) {
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
        return emergencyList.count
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
        self.textContactName.endEditing(true)
        self.textContactNumber.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textContactName.endEditing(true)
        self.textContactNumber.endEditing(true)
        return true
    }
    
    func animateIn()
    {
        self.view.addSubview(addContactView)
        addContactView.center = self.view.center
        addContactView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addContactView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.addContactView.alpha = 1
            self.addContactView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.addContactView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addContactView.alpha = 0
        }, completion: {(success: Bool) in
            self.addContactView.removeFromSuperview()
        })
    }
    

    @IBAction func addEmergencyContact(_ sender: Any) {
        
        
        if (AppDelegate.GlobalVariables.patientID != "Unknown")
        {
            chooseSourceAlertController()
        }
        else
        {
            promptMessage(title: "Device Not Paired", message: "Please pair the device before adding an emergency contact")
        }
        //animateIn()
    }
    
    func chooseSourceAlertController()
    {
        let alertController = UIAlertController(title: "Add Contact", message: "Please choose how you would like to add a new contact", preferredStyle: .actionSheet)
        
        let phoneButton = UIAlertAction(title: "Choose from phone contacts", style: .default, handler: { (action) -> Void in
            self.isFromPhonebook = true
            self.addcontactUsingPhonebook()
        })
        
        let  manualButton = UIAlertAction(title: "Type in the information", style: .default, handler: { (action) -> Void in
            self.isFromPhonebook = false
            self.animateIn()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(phoneButton)
        alertController.addAction(manualButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func promptMessage(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func addcontactUsingPhonebook()
    {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach { contact in

            var foundMobile: Bool = false
            if let name: String = contact.givenName {
                for number in contact.phoneNumbers {
                    if (number.label == "_$!<Mobile>!$_")
                    //if number.label == CNLabelPhoneNumberMobile
                    {
                        let phoneNumber = number.value.stringValue
                        let values: [String: Any]
                        values = ["name": name ?? "nil", "mobile": phoneNumber ?? "nil"]
                        print (values)
                        ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).child(phoneNumber).setValue(values)
                        foundMobile = true
                    }
                }
                if (!foundMobile)
                {
                    hasMobile = false
                }
                
            }
            else
            {
                if let name: String = contact.familyName {
                    for number in contact.phoneNumbers {
                        if (number.label == "_$!<Mobile>!$_")
                        //if number.label == CNLabelPhoneNumberMobile
                        {
                            let phoneNumber = number.value.stringValue
                            let values: [String: Any]
                            values = ["name": name ?? "nil", "mobile": phoneNumber ?? "nil"]
                            print (values)
                           ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).child(phoneNumber).setValue(values)
                            foundMobile = true
                        }
                    }
                    if (!foundMobile)
                    {
                        hasMobile = false
                    }
                }
            }
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    @IBAction func saveEmergencyContact(_ sender: Any) {
        
        var textName: String?
        var textMobile: String?
        
        textName = textContactName.text
        textMobile = textContactNumber.text
        
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
                if (selectedContact != nil)
                {
                    ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).child(selectedContact!).removeValue()
                    //ref?.child("emergencyContacts/testpatient").child(selectedContact!).removeValue()
                    selectedContact = nil
                }
                
                let values: [String: Any]
                values = ["name": textName ?? "nil", "mobile": textMobile ?? "nil"]
                ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).child(textMobile!).setValue(values)
                //ref?.child("emergencyContacts/testpatient").child(textMobile!).setValue(values)
                animateOut()
                self.textContactName.text = ""
                self.textContactNumber.text = ""
            }
        }
    }
    
    @IBAction func cancelAddContact(_ sender: Any) {
        animateOut()
        selectedContact = nil
        self.textContactName.text = ""
        self.textContactNumber.text = ""
    }
    
    func retrieveDataFromFirebase()
    {
        ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).observe(.value, with: {(snapshot) in
        //ref?.child("emergencyContacts/testpatient").observe(.value, with: {(snapshot) in
            
            if (self.isFromPhonebook && !self.hasMobile)
            {
                self.displayAlertMessage(title: "Error", message: "Contact(s) without a mobile number were not added")
                self.isFromPhonebook = false
                self.hasMobile = true
            }
            
            self.emergencyList.removeAllObjects()
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let name = value?["name"] as? String ?? ""
                let mobile = value?["mobile"] as? String ?? ""
                let newItem: EmergencyContact = EmergencyContact(name: name, mobile: mobile)
                
                self.emergencyList.add(newItem)
                
            }
            
            self.tableView.reloadData()
            if self.emergencyList.count == 0
            {
                self.noContactsLabel.text = "No emergency contacts to display"
            }
            else
            {
                self.noContactsLabel.text = ""
            }
        })
        
    }

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            // button to view the details of the category
            let editContact = UITableViewRowAction(style: .normal, title: "Edit")
            {action, indexPath in
                //self.selectedPosition = indexPath.row
                
                // TODO: edit this contact
                let e: EmergencyContact = self.emergencyList[indexPath.row] as! EmergencyContact
                self.selectedContact = e.mobile
                self.textContactName.text = e.name
                self.textContactNumber.text = e.mobile
                self.animateIn()
            }
            
            // button to delete the category from the list
            let delete = UITableViewRowAction(style: .normal, title: "Delete")
            {action, indexPath in
                
                // TODO: delete this item
                let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this contact?", preferredStyle: UIAlertControllerStyle.alert)
                
                deleteAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                    
                    self.ref?.child("emergencyContacts").child(AppDelegate.GlobalVariables.patientID).child(((self.emergencyList.object(at: indexPath.row)) as! EmergencyContact).mobile!).removeValue()
                    //self.ref?.child("emergencyContacts/testpatient").child(((self.emergencyList.object(at: indexPath.row)) as! EmergencyContact).mobile!).removeValue()
                    
                }))
                
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Delete cancelled")
                }))
                
                self.present(deleteAlert, animated: true, completion: nil)
            }
            
            // setting custom colours for each of the row buttons
            delete.backgroundColor = UIColor(colorLiteralRed: 233/255, green: 66/255, blue: 35/255, alpha: 1)
            editContact.backgroundColor = UIColor(colorLiteralRed: 45/255, green: 86/255, blue: 105/255, alpha: 1)
            return [editContact, delete]

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmergencyCell", for: indexPath) as! EmergencyTableViewCell

        // Configure the cell...
        let e: EmergencyContact = self.emergencyList[indexPath.row] as! EmergencyContact
        cell.contactNameLabel.text = e.name
        cell.contactNumberLabel.text = e.mobile
        cell.indexLabel.text = "\(indexPath.row + 1)"
        
        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let e: EmergencyContact = self.emergencyList[indexPath.row] as! EmergencyContact
        self.textContactName.text = e.name
        self.textContactNumber.text = e.mobile
        let mobileNumber: String = (e.mobile?.replacingOccurrences(of: " ", with: ""))!
            guard let number = URL(string: "telprompt://" + mobileNumber) else { return }
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        }

        //animateIn()


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
