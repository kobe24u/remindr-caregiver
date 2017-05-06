//
//  PhotoCollectionViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 7/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase

class PhotoCollectionViewController: UICollectionViewController, Table2Delegate, Table3Delegate, failedDelete
{
    
    var photos = [Photo]()
    var ref: FIRDatabaseReference!
    var selectedIndexPath: IndexPath!
    var chosenPhoto: Photo?
    var needRefresh: Bool?
    var photoToAdd: UIImage?
    var justAdded: Bool?
    
    
    struct Storyboard {
        
        static let leftAndRightPaddings: CGFloat = 2.0
        static let numberOfItemsPerRow: CGFloat = 3.0
    }
    
    func table2WillDismissed()
    {
        self.photos.removeAll()
        self.justAdded = true
    }
    
    func failDelete() {
        self.promptMessage(title: "Oops", message: "Sorry, you cannot delete the sample photo")
    }
    func detailVCDismissed() {
        print("delegate method called")
        self.photos.removeAll()
        self.promptMessage(title: "Easy", message: "You've successfully delete the photo")
    }
    
    func promptMessage(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        justAdded == false
        needRefresh = true
        let collectionViewWidth = collectionView?.frame.width
        let itemWidth = (collectionViewWidth! - Storyboard.leftAndRightPaddings) / Storyboard.numberOfItemsPerRow
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ref = FIRDatabase.database().reference()
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "addPhotoIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        
        
        
        
        
        
        btn1.addTarget(self, action: #selector(chooseSourceAlertController), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navigationItem.setRightBarButtonItems([item1], animated: true)

    }
    
    func chooseSourceAlertController()
    {
        let alertController = UIAlertController(title: "Where is the photo?", message: "Please choose an photo source", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Choose from photo library", style: .default, handler: { (action) -> Void in
            self.addphotoUsingLibrary()
        })
        
        let  deleteButton = UIAlertAction(title: "Take photo using camera", style: .default, handler: { (action) -> Void in
            self.addphotoUsingCamera()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        if needRefresh == true
        {
            retrieveDataFromFirebase()
        }
        
        if justAdded == true
        {
            self.promptMessage(title: "Ta-da!", message: "You've successfully added a new photo")
            self.justAdded = false
        }
        
    }
    
    func retrieveDataFromFirebase()
    {
        self.photos.removeAll()
        needRefresh = false
        // Retrieve the list of favourites and listen for changes
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.color = UIColor.black
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        ref.child("Photos").child(AppDelegate.GlobalVariables.patientID).observe(.value, with: {(snapshot) in
        //ref.child("Photos/testpatient").observe(.value, with: {(snapshot) in
            
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let Description = value?["Description"] as? String ?? ""
                let photoURL = value?["photoURL"]
                let audioURL = value?["audioURL"]
                if let imageURL = photoURL {
                    let url = NSURL(string: imageURL as! String)
                    URLSession.shared.dataTask(with: url! as URL,
                                               completionHandler: {(data, response, error) in
                                                
                                                if error != nil {
                                                    print(error)
                                                    return
                                                }
                                                
                                                let addingPhoto = UIImage(data: data!)
                                                
                                                
                                                let newPhoto = Photo(title: Description, featuredImage: addingPhoto!, audioURL: audioURL as! String)
                                                
                                                self.photos.append(newPhoto)
                                                
                                                DispatchQueue.main.async( execute: {
                                                    
                                                    self.collectionView?.reloadData()
                                                    activityView.stopAnimating()
                                                })
                                                print(self.photos.count)
                    }).resume()
                }
            }
            self.collectionView?.reloadData()
            
        })
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print(photos.count)
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCellCollectionViewCell
        cell.photo = photos[indexPath.item]
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let image = photos[indexPath.item].featuredImage
        
        self.chosenPhoto = photos[indexPath.item]
        
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowDetail", sender: image)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.image = sender as! UIImage
            detailVC.delegate = self
            detailVC.failDeleteDelegate = self
            detailVC.photoTitle = self.chosenPhoto!.title
            detailVC.audioURL = self.chosenPhoto!.audioURL
        }
    }
}

extension PhotoCollectionViewController : ZoomingViewController
{
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath {
            let cell = collectionView?.cellForItem(at: indexPath) as! PhotoCellCollectionViewCell
            return cell.photoImageView
        }
        
        return nil
    }
}
