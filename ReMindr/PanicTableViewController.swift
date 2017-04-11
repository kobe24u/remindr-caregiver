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
        return eventList.count
    }

    func retrieveDataFromFirebase()
    {
        
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
