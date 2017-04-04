//
//  FavouriteOnlyViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 28/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MapKit

class FavouriteOnlyViewController: UIViewController {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    //@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favouriteImage: UIImageView!
    var currentFavourite: Favourite?
    var lat: String?
    var lng: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = currentFavourite?.title
        // Do any additional setup after loading the view.
        
        // making label multiple lines
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.numberOfLines = 0
        
        //self.titleLabel.text = currentFavourite?.title
        self.descriptionLabel.text = currentFavourite?.desc
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
//                    favouriteImage.image = UIImage(data: data!)
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
                            self.favouriteImage.image = UIImage(data: data!)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
     Puts an annotation on the map if the current favourite had a previous location assigned to it
     */
    func addAnnotation()
    {
        print ("lat in view \(lat!)")
        if (lat! != "nil")     // if it has a previous latitude
        {
            let loc = CLLocationCoordinate2D(latitude: Double(lat!)!, longitude: Double(lng!)!)
            
            print("lat: \(lat)   lng: \(lng)")
            
            let region = (name: currentFavourite?.title, coordinate:loc)
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = region.coordinate
            mapAnnotation.title = region.name
            mapView.addAnnotation(mapAnnotation)
            
            // zooming into the area near the annotation
            let area = MKCoordinateRegion(center: loc , span: MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01))
            mapView.setRegion(area, animated: true)
            
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
