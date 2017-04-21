//
//  FastestRouteViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 20/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class FastestRouteViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var googleMapsURL: String?
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        
        if Reachability.isConnectedToNetwork() == false      // if data network exists
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // Do any additional setup after loading the view.
            print ("maps url : \(self.googleMapsURL)")
            
            showProgress()
            showRouteMap(completion: {
                (success) -> Void in
                if success {
                    self.activityView?.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
        
        
        
        //        webView.loadRequest(URLRequest(url: URL(string: googleMapsURL!)!))
        //        DispatchQueue.main.async( execute: {
        //            self.activityView?.stopAnimating()
        //        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showProgress()
    {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView?.color = UIColor.black
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func showRouteMap (completion: (_ success: Bool) -> Void) {
        self.webView.loadRequest(URLRequest(url: URL(string: googleMapsURL!)!))
        completion(true)
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
