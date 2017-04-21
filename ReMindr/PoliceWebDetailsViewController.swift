//
//  PoliceWebDetailsViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 20/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

class PoliceWebDetailsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var googleURL: String?
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Do any additional setup after loading the view.
        print ("maps url : \(self.googleURL)")
        
        showProgress()
        showRouteMap(completion: {
            (success) -> Void in
            if success {
                self.activityView?.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })

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
        self.webView.loadRequest(URLRequest(url: URL(string: googleURL!)!))
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
