//
//  SupportGroupSearchViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class SupportGroupSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var BASE_URL: String = "http://35.161.212.185"
    var SUPPORT_METHOD: String = "/supportgroupinfo/"
    
    var supportGroupList: NSMutableArray
    var matchedSupportGroupList: NSMutableArray
    var suburbNames = [String]()
    var selectedSuburb: String
    var selectedSupportGroup: SupportGroup?
    
    @IBOutlet weak var suburbPickerView: UIPickerView!
    @IBOutlet weak var supportGroupsTableView: UITableView!
    
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedSuburb = "All"
        self.supportGroupList = NSMutableArray()
        self.matchedSupportGroupList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.suburbPickerView.layer.cornerRadius = 10
        self.automaticallyAdjustsScrollViewInsets = false
        suburbNames.append("All")
        
        getAllSupportGroupInfo()
        //assignSuburbNames()
        
        supportGroupsTableView.delegate = self
        supportGroupsTableView.dataSource = self
        suburbPickerView.dataSource = self
        suburbPickerView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return suburbNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let textColor = UIColor(colorLiteralRed: 45/255, green: 86/255, blue: 105/255, alpha: 1)
        let attributedString = NSAttributedString(string: suburbNames[row], attributes: [NSForegroundColorAttributeName : textColor])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return suburbNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedSuburb = suburbNames[row]
            getMatchedSupportGroupInfo()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchedSupportGroupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupportGroupCell", for: indexPath) as! SupportGroupTableViewCell
        
        // Configure the cell...
        let sg: SupportGroup = self.matchedSupportGroupList[indexPath.row] as! SupportGroup
        cell.labelName.text = sg.name
        cell.labelContact.text = sg.contact
        cell.labelIndex.text = String(indexPath.row + 1)
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSupportGroup = matchedSupportGroupList[indexPath.row] as? SupportGroup
        performSegue(withIdentifier: "ShowCommunitySupportAnnotationDetails", sender: self)
    }
    
    
    func getMatchedSupportGroupInfo()
    {
        matchedSupportGroupList.removeAllObjects()
        if (selectedSuburb == "All")
        {
            matchedSupportGroupList.addObjects(from: supportGroupList as! [Any])
            sortMatchedListInAlphabeticalOrder()
            self.supportGroupsTableView.reloadData()
        }
        else
        {
            for current in supportGroupList
            {
                if ((current as! SupportGroup).suburb == selectedSuburb)
                {
                    matchedSupportGroupList.add(current)
                }
            }
            sortMatchedListInAlphabeticalOrder()
            self.supportGroupsTableView.reloadData()
        }
    }
    
    
    
    func getAllSupportGroupInfo()
    {
        var requestURL: String?
        requestURL = BASE_URL + SUPPORT_METHOD + "all"
        print ("request url is \(requestURL)")
        
        var url: NSURL = NSURL(string: requestURL!)!
        let task = URLSession.shared.dataTask(with: url as URL){
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage(title: "Connection Failed", message: "Failed to retrieve data from the server")
            }
            else
            {
                self.parseJSONData(groupsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseJSONData(groupsJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: groupsJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
              if let results = result as? NSArray
                {
                    for groupResult in results
                    {
                        if let currentResult: NSDictionary = groupResult as! NSDictionary
                        {
                            let newGroup: SupportGroup
                            if let name = currentResult.object(forKey: "Name") as? String
                            {
                                if let address = currentResult.object(forKey: "Address") as? String
                                {
                                    if let suburb = currentResult.object(forKey: "Suburb") as? String
                                    {
                                        if let state = currentResult.object(forKey: "State") as? String
                                        {
                                            if let postcode = currentResult.object(forKey: "Postcode") as? Int
                                            {
                                                if let contact = currentResult.object(forKey: "Phone") as? String
                                                {
                                                    if let email = currentResult.object(forKey: "Email") as? String
                                                    {
                                                        if let website = currentResult.object(forKey: "Website") as? String
                                                        {
                                                            if let latitude = currentResult.object(forKey: "Latitude") as? Double
                                                            {
                                                                if let longitude = currentResult.object(forKey: "Longitude") as? Double
                                                                {
                                                                    let mapsURL: String
                                                                    mapsURL = "https://www.google.com/maps/dir/current+location/\(latitude),\(longitude)"
                                                                    
                                                                        newGroup = SupportGroup(name: name, address: address, suburb: suburb, state: state, postcode: postcode, contact: contact, email: email, website: website, mapsURL: mapsURL, latitude: latitude, longitude: longitude)
                                                                        self.supportGroupList.add(newGroup)
                                                                        self.suburbNames.append(suburb)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            suburbNames = removeDuplicateSuburbs(array: suburbNames)
            sortListInAlpahbeticalOrder()
            self.suburbPickerView.reloadAllComponents()
        }
        
        catch{
            print("JSON Serialization error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowCommunitySupportAnnotationDetails")
        {
            print(selectedSupportGroup?.name)
            let destinationVC: SupportGroupDetailsViewController = segue.destination as! SupportGroupDetailsViewController
            destinationVC.currentSupportGroup = selectedSupportGroup
        }
    }
    
    func removeDuplicateSuburbs(array: [String]) -> [String]
    {
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0)
            else {
                return false
            }
            set.insert($0)
            return true
        }
        return result
    }
    
    func sortListInAlpahbeticalOrder()
    {
        suburbNames = suburbNames.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
    func sortMatchedListInAlphabeticalOrder()
    {
        let sortedList = matchedSupportGroupList.sortedArray(comparator: {
            (object1, object2) -> ComparisonResult in
            let support1 = object1 as! SupportGroup
            let support2 = object2 as! SupportGroup
            let result = support1.name!.compare(support2.name!)
            return result
        })
        matchedSupportGroupList.setArray(sortedList)
    }
    
    /*
    func assignSuburbNames()
    {
        for currentGroup in supportGroupList
        {
            let group: SupportGroup = currentGroup as! SupportGroup
            self.suburbNames.append(group.suburb!)
        }
        self.suburbPickerView.reloadAllComponents()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
