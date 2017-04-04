//
//  EditFavouriteViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 28/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol updatedFavouriteDelegate {
    func updateNewFavourite(updatedFavourite: Favourite)
}

class EditFavouriteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,addLocationDelegate {

    var currentFavourite: Favourite?
    var delegate: updatedFavouriteDelegate?
    var desc: String?
    var lat: String?
    var lng: String?
    var imageURL: String?
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference
    
    @IBOutlet weak var imageFavourite: UIImageView!
    @IBOutlet weak var textTitle: UITextField!

    @IBOutlet weak var textDescription: UITextView!
    
    @IBOutlet weak var textAssignedLocation: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        desc = nil   // default nil for description since it is optional
        lat = nil       // default nil for lat since it is optional
        lng = nil    // default nil for lng since it is optional
        imageURL = nil
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        imageFavourite.layer.cornerRadius = 5
        imageFavourite.clipsToBounds = true;
        
        assignLabels()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //assignLabels()
    }
    
    // redirects the flow to the map view where the user can set the latitude and longitude values based on the address given
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateLocationSegue"
        {
            let destinationVC: LocationViewController = segue.destination as! LocationViewController
            
            if (lat! != "nil")
            {
                destinationVC.lat = Double(lat!)
                destinationVC.lng = Double(lng!)
            }
            destinationVC.favName = (currentFavourite?.title)!
            destinationVC.delegate = self
        }
    }

    @IBAction func editImage(_ sender: Any) {
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
            imageFavourite.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Chose to cancel selection of image")
        dismiss(animated: true, completion: nil)
    }

    // this delegate method receives the latitude and longitude values from the map view and assigns it to the lat lng variables
    func addLocation (lat: Double, lng: Double)
    {
        textAssignedLocation.text = ""
        self.currentFavourite?.lat = String(lat)
        self.currentFavourite?.lng = String(lng)
        self.lat = String(lat)
        self.lng = String(lng)
        print("in edit class lat and lng \(self.lat) \(self.lng)")
        textAssignedLocation.text = "Location has been assigned."
    }
    
    @IBAction func updateFavourite(_ sender: Any) {
        let title: String
        let desc: String
        title = textTitle.text!
        desc = textDescription.text!
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
            if (self.lat == nil || self.lng == nil)
            {
                self.lat = "nil"
                self.lng = "nil"
            }
            
            //print ("at save in edit self. lat lng \(self.lat) \(self.lng)")
            // if you want a unique string for whatever reason
            // let uniqueString = NSUUID().UUIDString
            
            // storing the image into the Firebase storage
            
            var imageDownloadURL: String?
            imageDownloadURL = currentFavourite?.imageURL!
            
            if let uploadData = UIImagePNGRepresentation(imageFavourite.image!) {
                
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
                        imageDownloadURL = imageURL
                        values = ["title": title, "desc": desc, "status": status, "imageURL": imageURL, "lat": self.lat ?? "nil", "lng": self.lng ?? "nil"]
                        
                    }
                    else
                    {
                        imageDownloadURL = "nil"
                        values = ["title": title, "desc": desc, "status": status, "imageURL": "nil", "lat": self.lat ?? "nil", "lng": self.lng ?? "nil"]
                    }
                    
                    self.ref.child("favourites").child("testpatient").child((self.currentFavourite?.title)!).removeValue()
                    
                    self.currentFavourite = Favourite(title: title, desc: desc, status: status, imageURL: imageDownloadURL!, lat: self.lat!, lng: self.lng!)
                    
                    self.ref.child("favourites/testpatient").child(title).setValue(values)
                    print ("at save in edit currentFavourite. lat lng \(self.currentFavourite?.lat) \(self.currentFavourite?.lng)")
                    
                    self.delegate?.updateNewFavourite(updatedFavourite: self.currentFavourite!)
                    self.navigationController?.popViewController(animated: true)
                })
            }

            else
            {
                print("the other condition with no picture")
            }
            
            
            //let values = ["title": title, "desc": desc, "status": status, "imageURL": currentFavourite?.imageURL ?? "nil", "lat": self.lat ?? "nil", "lng": self.lng ?? "nil"] as [String : Any]
            
            /*
            self.ref.child("favourites").child("testpatient").child((currentFavourite?.title)!).removeValue()
            self.ref.child("favourites").child("testpatient").child(title).child("title").setValue(title)
            self.ref.child("favourites").child("testpatient").child(title).child("desc").setValue(desc)
            
            self.ref.child("favourites").child("testpatient").child(title).child("status").setValue(status)
            self.ref.child("favourites").child("testpatient").child(title).child("imageURL").setValue(currentFavourite?.imageURL)
            self.ref.child("favourites").child("testpatient").child(title).child("lat").setValue(self.lat)
            self.ref.child("favourites").child("testpatient").child(title).child("lng").setValue(self.lng)
            
            */
            
            
           // self.currentFavourite = Favourite(title: title, desc: desc, status: status, imageURL: "nil", lat: self.lat!, lng: self.lng!)
 

           // self.navigationController?.popViewController(animated: true)
        }

    }

    func displayAlertMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func assignLabels()
    {
        self.textAssignedLocation.text = ""
        self.textTitle.text = currentFavourite?.title
        self.textDescription.text = currentFavourite?.desc
        if (currentFavourite?.imageURL != nil && currentFavourite!.imageURL! != "nil")
        {
            print (currentFavourite!.imageURL!)
            let url = URL(string: (currentFavourite?.imageURL)!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageFavourite.image = UIImage(data: data!)
            
        }
        
        self.lat = currentFavourite?.lat
        self.lng = currentFavourite?.lng
        
        if (self.lat != "nil")
        {
            textAssignedLocation.text = "A location has been assigned."
        }
        
        if (currentFavourite?.status == "Good")
        {
            self.segmentControl.selectedSegmentIndex = 0;
        }
        else
        {
            self.segmentControl.selectedSegmentIndex = 1;
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

}
