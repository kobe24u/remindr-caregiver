//
//  AddReminderViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 22/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    var reminder: Reminder?
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // set self as delegate for text field
        reminderTextField.delegate = self
        checkName()
        // set now as minimum date for picker
        timePicker.minimumDate = Date()
        timePicker.locale = Locale.current
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
        reminderTextField.returnKeyType = .done
        
        
        hideKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkName() {
        // Disable the Save button if the text field is empty.
        let text = reminderTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func checkDate() {
        // Disable the Save button if date has passed
        if (Date() as NSDate).earlierDate(timePicker.date) == timePicker.date {
            saveButton.isEnabled = false
        }
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
    
    // UIDatePickerDelegate
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        checkDate()
    }
    
    // Cancel button
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sender as AnyObject? === saveButton {
            let name = reminderTextField.text
            var time = timePicker.date
            let timeInterval = floor(time.timeIntervalSinceReferenceDate/60)*60
            time = Date(timeIntervalSinceReferenceDate: timeInterval)
            let uuid = UUID().uuidString
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let values = ["id": uuid, "message": name, "time": dateFormatter.string(from: time), "completed": "no"] as [String : Any]
            self.ref.child("reminders").child(AppDelegate.GlobalVariables.patientID).child(uuid).setValue(values)
            //self.ref.child("reminders/testpatient").child(uuid).setValue(values)
            
            // build notification
            let notification = UILocalNotification()
            notification.alertTitle = "Reminder"
            notification.alertBody = "Don't forget to \(name!)!"
//            notification.fireDate = time
            notification.soundName = UILocalNotificationDefaultSoundName
            
//            UIApplication.shared.scheduleLocalNotification(notification)
            
            reminder = Reminder(name: name!, time: time, notification: notification, completed: "no", uuid: uuid)
        }
    }
    
    
}
