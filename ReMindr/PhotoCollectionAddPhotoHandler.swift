//
//  PhotoCollectionAddPhotoHandler.swift
//  ReMindr
//
//  Created by Vincent Liu on 7/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase

extension PhotoCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    func addphotoUsingCamera(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = UIImagePickerControllerSourceType.camera
        
        present(picker, animated: true, completion: nil)
    }
    
    func addphotoUsingLibrary(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    
    fileprivate func addPhotoIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("Photos").child(AppDelegate.GlobalVariables.patientID).child(uid)
        //let usersReference = ref.child("Photos").child("testpatient").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
        })
    }

    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as! UIImage?
        {
            self.photoToAdd = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage?
        {
            self.photoToAdd = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
        
//     let newViewController: photoInfoViewController = photoInfoViewController()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc  = storyboard.instantiateViewController(withIdentifier: "photoInforController") as! photoInfoViewController
        
        vc.del = self
       
        vc.chosenImage = self.photoToAdd
        
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showInputDialog(){
                //Creating UIAlertController and
                //Setting title and message for the alert dialog
                let alertController = UIAlertController(title: "Notice", message: "Enter a description for the photo, \n e.g This is my son.", preferredStyle: .alert)
        
                //the confirm action taking the inputs
                let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
        
                    //getting the input values from user
                    let photoDesc = (alertController.textFields?[0].text)!
                    if photoDesc.isEmpty
                    {
                        self.promptMessage(title: "Oops", message: "The description cannot be null")
        
                    }
                    else{
//                        let newPhoto = Photo(title: photoDesc, featuredImage: self.photoToAdd!, audioURL: "none")
                        
                        let imageName = NSUUID().uuidString
                        let storageRef = FIRStorage.storage().reference().child("added_photos").child("\(imageName).png")
                        
                        if let uploadData = UIImagePNGRepresentation(self.photoToAdd!) {
                            
                            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                
                                if let error = error {
                                    print(error)
                                    return
                                }
                                
                                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                                    
                                    let values = ["Description": photoDesc, "photoURL": imageUrl, "audioURL": "none"]
                                    self.addPhotoIntoDatabaseWithUID(imageName, values: values as [String : AnyObject])
                                    self.photos.removeAll()
                                    self.turnToRecording()
                                    
                                    
                                }
                            })
                        }
                        

                    }
        
                }
        
                //the cancel action doing nothing
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
                //adding textfields to our dialog box
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter Name"
                }
        
        
                //adding the action to dialogbox
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
        
                //finally presenting the dialog box
                self.present(alertController, animated: true, completion: nil)
        
            }
        
            
    
    
            func turnToRecording()
            {
                let alertController = UIAlertController(title: "Notice", message: "Please record an audio clip for the patient.", preferredStyle: .alert)
                
                //the confirm action taking the inputs
                let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
                    self.photos.removeAll()
                    self.promptMessage(title: "Ta-da!", message: "You've successfully added a new photo")
                    }
   
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                
                
                
                
                //adding the action to dialogbox
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                //finally presenting the dialog box
                self.present(alertController, animated: true, completion: nil)

            }
}
