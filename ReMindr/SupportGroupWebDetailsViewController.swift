//
//  SupportGroupWebDetailsViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class SupportGroupWebDetailsViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlToLoad: String?
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // Do any additional setup after loading the view.
            print ("url : \(self.urlToLoad)")
            
            showProgress()
            loadURLRequest(completion: {
                (success) -> Void in
                if success {
                    self.activityView?.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        }
        
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
    
    func loadURLRequest (completion: (_ success: Bool) -> Void) {
        self.webView.loadRequest(URLRequest(url: URL(string: urlToLoad!)!))
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
