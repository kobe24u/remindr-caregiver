//
//  ModifyViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 1/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol EditReminderProtocol {
    func editReminder(reminder: Reminder)
}

class ModifyViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    var delegate: EditReminderProtocol?
    var reminder: Reminder?
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    @IBAction func finishEditing(_ sender: Any) {
        let name = descTextField.text
        var time = datePicker.date
        let timeInterval = floor(time.timeIntervalSinceReferenceDate/60)*60
        time = Date(timeIntervalSinceReferenceDate: timeInterval)
        let uuid = UUID().uuidString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let values = ["message": name, "time": dateFormatter.string(from: time)] as [String : Any]
        self.ref.child("reminders").child(AppDelegate.GlobalVariables.patientID).child(uuid).setValue(values)
        //self.ref.child("reminders/testpatient").child(uuid).setValue(values)
        
        // build notification
        let notification = UILocalNotification()
        notification.alertTitle = "Reminder"
        notification.alertBody = "Don't forget to \(name!)!"
        notification.fireDate = time
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(notification)
        
        reminder = Reminder(name: name!, time: time, notification: notification, completed: "no", uuid: uuid)
        
        self.delegate?.editReminder(reminder: reminder!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkDate() {
        // Disable the Save button if date has passed
        if (Date() as NSDate).earlierDate(datePicker.date) == datePicker.date {
            saveButton.isEnabled = false
        }
    }
    
    func checkName() {
        // Disable the Save button if the text field is empty.
        let text = descTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descTextField.delegate = self
        if self.reminder != nil
        {
            descTextField.text = reminder?.name
            datePicker.date = (reminder?.time)!
        }
        checkName()
        repeatSwitch.isOn = false
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        checkDate()
    }
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    

}
