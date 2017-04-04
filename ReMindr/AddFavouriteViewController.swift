//
//  AddFavouriteViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFavouriteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, addLocationDelegate{

    var lat: String?
    var lng: String?
    
    @IBOutlet weak var textAssignedLocation: UILabel!
    @IBOutlet weak var textTitle: UITextField!
  
    @IBOutlet weak var textAreaDescription: UITextView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var itemImageView: UIImageView!
    
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var newFav: Favourite?
    
    required init?(coder aDecoder: NSCoder) {
        
        // initializing Firebase references
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
        lat = nil    // default nil for lat since it is optional
        lng = nil    // default nil for lng since it is optional
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //ref = FIRDatabase.database().reference()
        self.textAssignedLocation.text = ""
        newFav = Favourite()
        
        //To make the border look very close to a UITextField
        textAreaDescription.layer.cornerRadius = 5
        textAreaDescription.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        textAreaDescription.layer.borderWidth = 0.5
        textAreaDescription.clipsToBounds = true

        itemImageView.layer.cornerRadius = 5
        itemImageView.clipsToBounds = true;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Chose an image")
        
        var selectedImageFromPicker: UIImage?
        
        // there is an image component called the original image
        // we are trying to get that outside the picker
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage as? UIImage
        }
            // if you can't find the edited image then pick the original image
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            itemImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Chose to cancel selection of image")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addLocation(_ sender: Any) {
    }
    
    @IBAction func addFavourite(_ sender: Any) {
        
        let title: String
        let desc: String
        title = textTitle.text!
        desc = textAreaDescription.text!
        let status: String
        let selectedStatus = segmentControl.selectedSegmentIndex
        if (selectedStatus == 0)
        {
            status = "Good"
        }
        else
        {
            status = "Bad"
        }
        
        if (title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
        {
            displayAlertMessage(title: "Alert", message: "Title and Description are mandatory")
        }
        else
        {
            if (lat == nil || lng == nil)
            {
                self.lat = "nil"
                self.lng = "nil"
            }
            
            // if you want a unique string for whatever reason
            // let uniqueString = NSUUID().UUIDString
            
            // storing the image into the Firebase storage
            if let uploadData = UIImagePNGRepresentation(itemImageView.image!) {
                
                print ("upload image is \(uploadData)")
                
                
                let imageTitle = "favourites/\(title)_testpatient.png"
                
                storageRef.child(imageTitle).put(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if (error != nil)
                    {
                        print ("an error occurred while trying to upload: \(error.debugDescription)")
                        self.displayAlertMessage(title: "Server Error", message: "Unable to upload image to the cloud storage")
                    }
                    print(metadata)
                
                    print ("metadata path \(metadata?.downloadURL()?.absoluteString)")
                    let values: [String: Any]
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        print ("path of the image \(imageURL)")
                        values = ["title": title, "desc": desc, "status": status, "imageURL": imageURL, "lat": self.lat ?? "nil", "lng": self.lng ?? "nil"]

                    }
                    else
                    {
                        values = ["title": title, "desc": desc, "status": status, "imageURL": "nil", "lat": self.lat ?? "nil", "lng": self.lng ?? "nil"]
                    }
                    
                    self.ref.child("favourites/testpatient").child(title).setValue(values)
                    self.navigationController?.popViewController(animated: true)
                })
            }
            
            /*
            self.ref?.child("favourites").child("testpatient").child(title).child("title").setValue(title)
            self.ref?.child("favourites").child("testpatient").child(title).child("desc").setValue(desc)
            
            self.ref?.child("favourites").child("testpatient").child(title).child("status").setValue(status)
            self.ref?.child("favourites").child("testpatient").child(title).child("imageURL").setValue("nil")
            self.ref?.child("favourites").child("testpatient").child(title).child("lat").setValue(self.lat)
            self.ref?.child("favourites").child("testpatient").child(title).child("lng").setValue(self.lng)
            */

            
        }
 
    }
    
    // redirects the user to a mapView that allows the user to input and address and let the Map assign a latitude and longitude corresponding to the address
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AssignLocationSegue"
        {
            let destinationVC: LocationViewController = segue.destination as! LocationViewController
            destinationVC.delegate = self
        }
    }
    
    // receiving the latitude and longitude from the map view controller class
    func addLocation (lat: Double, lng: Double)
    {
        textAssignedLocation.text=""
        self.lat = String(lat)
        self.lng = String(lng)
        textAssignedLocation.text = "Location has been assigned."
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
