//
//  NotificationTableViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 22/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NotificationTableViewController: UITableViewController, EditReminderProtocol {
    // Properties
    var reminders = [Reminder]()
    let dateFormatter = DateFormatter()
    let locale = Locale.current
    var ref: FIRDatabaseReference!
    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ref = FIRDatabase.database().reference()
        retrieveFromServer()
        
        tableView.reloadData()
    }
    
//    override func viewWillAppear(_ animated: Bool)
//    {
//        
//        retrieveFromServer()
//    }
    
    func retrieveFromServer()
    {
        self.reminders.removeAll()
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.color = UIColor.black
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        ref.child("reminders/testpatient").observe(.value, with: {(snapshot) in
            
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let message = value?["message"] as? String ?? ""
                let time = value?["time"]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: time as! String)
                
                let notification = UILocalNotification()
                notification.alertTitle = "Reminder"
                notification.alertBody = "\(message)"
                notification.fireDate = date
                notification.soundName = UILocalNotificationDefaultSoundName
                
                let newReminder = Reminder(name: message, time: date!, notification: notification)
                 self.reminders.append(newReminder)
                print(self.reminders.count)
                                                DispatchQueue.main.async( execute: {
                                                    
                                                    self.tableView?.reloadData()
                                                    activityView.stopAnimating()
                                                })
                                                print(self.reminders.count)
                
            
            }
            self.tableView?.reloadData()
            
        })
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        tableView.reloadData()
//    }
    
    // Table view data
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "reminderCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        print(reminders.count)
        let reminder = reminders[indexPath.row]
        // Fetches the appropriate info if reminder exists
        cell.textLabel?.text = reminder.name
        cell.detailTextLabel?.text = "Due " + dateFormatter.string(from: reminder.time as Date)
        
        // Make due date red if overdue
        if (Date() as NSDate).earlierDate(reminder.time as Date) == reminder.time as Date {
            cell.detailTextLabel?.textColor = UIColor.red
        }
        else {
            cell.detailTextLabel?.textColor = UIColor.blue
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedRow = indexPath.row
//        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "modifyReminder") as! ModifyViewController
//        let reminder = reminders[indexPath.row]
//        popoverVC.reminder = reminder
//        popoverVC.delegate = self
//        self.present(popoverVC, animated: true, completion: nil)
//    }
    
    func editReminder(reminder: Reminder) {
        reminders[self.selectedRow!] = reminder
        self.reminders.removeAll()
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this reminder?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                
                
                
                let ref = FIRDatabase.database().reference().child("reminders").child("testpatient")
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    
                    for current in snapshot.children.allObjects as! [FIRDataSnapshot]
                    {
                        let value = current.value as? NSDictionary
                        let message = value?["message"] as! String
                        let time = value?["time"] as! String
                        let reminder = self.reminders[indexPath.row]
                        
                            if message == reminder.name
                            {
                                current.ref.removeValue()
                                let toRemove = self.reminders.remove(at: indexPath.row)
                                UIApplication.shared.cancelLocalNotification(toRemove.notification)
                                self.saveReminders()
                                tableView.deleteRows(at: [indexPath], with: .fade)
                                self.reminders.removeAll()
                                tableView.reloadData()
                                return
                            }

                        
                        
                        
                    }
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
                
//                self.retrieveFromServer()
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Delete cancelled")
            }))
            
            present(deleteAlert, animated: true, completion: nil)
            
            
            
            
            
            
            // Delete the row from the data source
//            let toRemove = reminders.remove(at: indexPath.row)
//            UIApplication.shared.cancelLocalNotification(toRemove.notification)
//            saveReminders()
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // NSCoding
    
    func saveReminders() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save reminders...")
        }
    }
    
    func loadReminders() -> [Reminder]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.ArchiveURL.path) as? [Reminder]
    }
    
    // When returning from AddReminderViewController
    @IBAction func unwindToReminderList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddReminderViewController, let reminder = sourceViewController.reminder {
//            // add a new reminder
//            let newIndexPath = IndexPath(row: reminders.count, section: 0)
//            reminders.append(reminder)
//            tableView.insertRows(at: [newIndexPath], with: .bottom)
//            saveReminders()
//            tableView.reloadData()
//            retrieveFromServer()
            self.reminders.removeAll()
        }
    }
}
