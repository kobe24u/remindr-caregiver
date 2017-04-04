//
//  ViewFavouriteViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit

class ViewFavouriteViewController: UIViewController, updatedFavouriteDelegate {

    // declaring global variables
    var currentFavourite: Favourite?
    var lat: String?
    var lng: String?
    
    //@IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageFavourite: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var mapLocation: MKMapView!
    @IBOutlet weak var statusImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = currentFavourite?.title
        // making label multiple lines
        self.labelDescription.lineBreakMode = .byWordWrapping
        self.labelDescription.numberOfLines = 0
        
        // Do any additional setup after loading the view.
        //self.labelTitle.text = currentFavourite?.title
        
        /*
        self.labelDescription.text = currentFavourite?.desc
        self.lat = currentFavourite?.lat!
        self.lng = currentFavourite?.lng!
        
        let isNil = (currentFavourite?.imageURL! == "nil")
        let isEmpty = currentFavourite?.imageURL?.isEmpty
        
        if !(isEmpty!)
        {
            if !isNil
            {
//                if (currentFavourite?.imageURL != nil)
//                {
//                    let url = URL(string: (currentFavourite?.imageURL)!)
//                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    imageFavourite.image = UIImage(data: data!)
//                }
                if let favImageURL = currentFavourite?.imageURL {
                    let url = URL(string: favImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        
                        if error != nil
                        {
                            print (error)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.imageFavourite.image = UIImage(data: data!)
                        }
                        
                    }).resume()
                }

                
            }
                
        }
        */
        assignLabels()
        addAnnotation()
        
//            if let filePath = Bundle.main.path(forResource: "imageName", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
//                imageFavourite.contentMode = .scaleAspectFit
//                imageFavourite.image = image
//            }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assignLabels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFavouriteSegue"
        {
            let destinationVC: EditFavouriteViewController = segue.destination as! EditFavouriteViewController
            destinationVC.currentFavourite = currentFavourite
            destinationVC.delegate = self
        }
        
    }
    
    /*
     Puts an annotation on the map if the current favourite had a previous location assigned to it
     */
    func addAnnotation()
    {
        let allAnnotations = self.mapLocation.annotations
        self.mapLocation.removeAnnotations(allAnnotations)
        
        print ("lat in view \(self.lat!)")
        if (self.lat! != "nil")     // if it has a previous latitude
        {
            let loc = CLLocationCoordinate2D(latitude: Double(lat!)!, longitude: Double(lng!)!)
            
            print("lat: \(lat)   lng: \(lng)")
            
            let region = (name: currentFavourite?.title, coordinate:loc)
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = region.coordinate
            mapAnnotation.title = region.name
            mapLocation.addAnnotation(mapAnnotation)
            
            // zooming into the area near the annotation
            let area = MKCoordinateRegion(center: loc , span: MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01))
            mapLocation.setRegion(area, animated: true)

        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func assignLabels()
    {
        //self.labelTitle.text = currentFavourite?.title
        self.title = currentFavourite?.title
        self.labelDescription.text = currentFavourite?.desc
        self.lat = currentFavourite?.lat!
        self.lng = currentFavourite?.lng!
        
        let isNil = (currentFavourite?.imageURL! == "nil")
        let isEmpty = currentFavourite?.imageURL?.isEmpty
        
        if !(isEmpty!)
        {
            if !isNil
            {
//                if (currentFavourite?.imageURL != nil)
//                {
//                    let url = URL(string: (currentFavourite?.imageURL)!)
//                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    imageFavourite.image = UIImage(data: data!)
//                }
                
                if let favImageURL = currentFavourite?.imageURL {
                    let url = URL(string: favImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        
                        if error != nil
                        {
                            print (error)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.imageFavourite.image = UIImage(data: data!)
                        }
                    
                    }).resume()
                }
                

                
            }
            
        }
        
                if (currentFavourite?.status == "Good")
        {
            self.statusImage.image = #imageLiteral(resourceName: "do")
        }
        else
        {
            self.statusImage.image = #imageLiteral(resourceName: "don't")
        }
        
        addAnnotation()
    }

    func updateNewFavourite(updatedFavourite: Favourite) {
        self.currentFavourite?.title = updatedFavourite.title
        self.currentFavourite?.desc = updatedFavourite.desc
        self.currentFavourite?.imageURL = updatedFavourite.imageURL
        self.currentFavourite?.lat = updatedFavourite.lat
        self.currentFavourite?.lng = updatedFavourite.lng
        self.currentFavourite?.status = updatedFavourite.status
        
        print (" new favourite item has lat \(updatedFavourite.lat)")
        assignLabels()
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
