//
//  PanicTableViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 11/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase

class PanicTableViewController: UITableViewController {

    @IBOutlet weak var noItemsLabel: UILabel!
    
    var eventList: NSMutableArray
    var ref: FIRDatabaseReference!
    
    required init?(coder aDecoder: NSCoder) {
        self.eventList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        noItemsLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // checking if network is available (Reachability class is defined in another file)
        if Reachability.isConnectedToNetwork() == false      // if data network exists
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else
        {
            retrieveDataFromFirebase()
        }
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
        return eventList.count
    }

    func retrieveDataFromFirebase()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let date: NSDate
        date = dateFormatter.date(from: "14-04-2017 16:03:11")! as NSDate
        print ("the scam date is \(date)")
        
        // Retrieve the list of favourites and listen for changes
        ref.child("panicEvents/testpatient").observe(.value, with: {(snapshot) in
            
            self.eventList.removeAllObjects()
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let eventName = value?["eventName"] as? String ?? ""
                let receivedDate = value?["receivedDate"] as? String ?? ""
                let receivedTime = value?["receivedTime"] as? String ?? ""
                let receivedLat = value?["receivedLat"] as? String ?? ""
                let receivedLng = value?["receivedLng"] as? String ?? ""
                let resolved = value?["resolved"] as? String ?? ""
                let resolvedDate = value?["resolvedDate"] as? String ?? ""
                let resolvedTime = value?["resolvedTime"] as? String ?? ""
                let newItem = Panic(eventName: eventName, receivedDate: receivedDate, receivedTime: receivedTime, receivedLat: receivedLat, receivedLng: receivedLng, resolved: resolved)

                self.eventList.add(newItem)
                
            }
            self.tableView.reloadData()
            if self.eventList.count == 0
            {
                self.noItemsLabel.text = "No events to display"
            }
            else
            {
                self.noItemsLabel.text = ""
                self.sortEventList()
            }
        })
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PanicCell", for: indexPath) as! PanicTableViewCell

        let event: Panic = (self.eventList[indexPath.row] as? Panic)!
        cell.panicDate.text = event.receivedDate
        cell.panicTime.text = event.receivedTime
        
        print ("event resolved \(event.resolved!)")
        if (event.resolved! == "true")
        {
            cell.panicImage.image = #imageLiteral(resourceName: "handledgreen")
        }
        else
        {
            cell.panicImage.image = #imageLiteral(resourceName: "alertred.png")
        }

        return cell
    }


    //TODO: sort events by date and time
    //TODO: sort events by resolved true or false
    //TODO: check item as resolved; delete event; view event
    
 
 
    
    /*
     A function to sort the reminders list based on whether the due date is set or not
     The function splits the array based on due date (those with a due date and those without)
     and send the list with the due date to the ordering function that orders it by due date.
     The two lists are then appended together
     */
    func sortEventList()
    {
        var listWithResolvedEvents: NSMutableArray    // array to store the events which are resolved
        var listWithUnresolvedEvents: NSMutableArray   // array to store events that are not resolved
//        var listWithDate: NSMutableArray
//        var listWithoutDate: NSMutableArray
//        listWithDate = NSMutableArray()
//        listWithoutDate = NSMutableArray()
        listWithResolvedEvents = NSMutableArray()
        listWithUnresolvedEvents = NSMutableArray()
        
        //looping through the reminder list
        for event in (eventList as NSArray as! [Panic])
        {
            if event.resolved == "true"
            {
                listWithResolvedEvents.add(event)
            }
            else
            {
                listWithUnresolvedEvents.add(event)
            }
        }
        
        /*
        // looping through the incomplete reminders list
        for reminder in (listWithUnresolvedEvents as NSArray as! [Panic])
        {
            if reminder.dueDate != nil      // if reminder has due date
            {
                listWithDate.addObject(reminder)
            }
            else                            // if reminder doesn't have due date
            {
                listWithoutDate.addObject(reminder)
            }
        }
        
        // sending the list to be ordered by due date
        listWithDate = orderReminderListByDueDate(listWithDate)
 
 */
        // clearing the main list
        eventList.removeAllObjects()
       
//        // appending the newly sorted lists
//        reminderList.addObjectsFromArray(listWithDate as [AnyObject])
//        reminderList.addObjectsFromArray(listWithoutDate as [AnyObject])
 
        eventList.addObjects(from: listWithUnresolvedEvents as [AnyObject])
        eventList.addObjects(from: listWithResolvedEvents as [AnyObject])
        
        self.tableView.reloadData()
    }
    
    /*
    /*
     This function is used to sort the reminders list by comparing the due dates of the reminders
     Adapted from a code retrieved from http://stackoverflow.com/questions/25769107/sort-nsarray-with-sortedarrayusingcomparator
     Author: Mike S and Miro
     Date: 08/09/2016
     */
    func orderEventListByDateTime(reminderList: NSMutableArray) -> NSMutableArray
    {
        let sortedList = reminderList.sortedArrayUsingComparator{
            (object1, object2) -> NSComparisonResult in
            let rem1 = object1 as! Item
            let rem2 = object2 as! Item
            let result = rem1.dueDate!.compare(rem2.dueDate!)
            return result
        }
        reminderList.setArray(sortedList)
        return reminderList
    }
    */
    
    
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
 
 
 
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // button to view the details of the category
        let resolveEvent = UITableViewRowAction(style: .normal, title: "Resolved")
        {action, indexPath in
            //self.selectedPosition = indexPath.row
            
            // TODO: set this item as resolved
            let dateTime = NSDate()
            print (dateTime)
            
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            timeFormatter.dateFormat = "HH:mm:ss"
            
            let dateResult = dateFormatter.string(from: dateTime as Date)
            let timeResult = timeFormatter.string(from: dateTime as Date)
           
            
            self.ref?.child("panicEvents/testpatient").child(((self.eventList.object(at: indexPath.row)) as! Panic).eventName!).child("resolved").setValue("true")
            self.ref?.child("panicEvents/testpatient").child(((self.eventList.object(at: indexPath.row)) as! Panic).eventName!).child("resolvedDate").setValue(dateResult)
            self.ref?.child("panicEvents/testpatient").child(((self.eventList.object(at: indexPath.row)) as! Panic).eventName!).child("resolvedTime").setValue(timeResult)
            
            
        }
        
        // button to delete the category from the list
        let delete = UITableViewRowAction(style: .normal, title: "Delete")
        {action, indexPath in
            
          // TODO: delete this item
            let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                
                
                self.ref?.child("panicEvents/testpatient").child(((self.eventList.object(at: indexPath.row)) as! Panic).eventName!).removeValue()
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Delete cancelled")
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)

        }
        
        // setting custom colours for each of the row buttons
        delete.backgroundColor = UIColor(colorLiteralRed: 233/255, green: 66/255, blue: 35/255, alpha: 1)
        resolveEvent.backgroundColor = UIColor(colorLiteralRed: 50/255, green: 151/255, blue: 94/255, alpha: 1)
        
        if (((self.eventList.object(at: indexPath.row)) as! Panic).resolved == "true")
        {
            return [delete]
        }
        else
        {
            return [resolveEvent, delete]
        }
        
    }

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
