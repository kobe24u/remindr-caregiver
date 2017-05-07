//
//  SupportGroupDetailsViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 3/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import MessageUI

class SupportGroupDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var currentSupportGroup: SupportGroup?
    var requestedURL: String?
    var isWebsite: Bool?
    
    @IBOutlet weak var supportImage: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var callTextButton: UIButton!
    
    @IBOutlet weak var callImageButton: UIButton!
    
    @IBOutlet weak var emailTextButton: UIButton!
    
    @IBOutlet weak var emailImageButton: UIButton!
    
    @IBOutlet weak var websiteTextButton: UIButton!
    
    @IBOutlet weak var websiteImageButton: UIButton!
    
    @IBOutlet weak var locationTextButton: UIButton!
    
    @IBOutlet weak var locationImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.labelAddress.lineBreakMode = .byWordWrapping
        self.labelAddress.numberOfLines = 0
        assignLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func callSupportGroup1(_ sender: Any) {
        var phNumber: String
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: "(", with: ""))!
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: ")", with: ""))!
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: " ", with: ""))!
        guard let number = URL(string: "telprompt://" + phNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    @IBAction func callSupportGroup2(_ sender: Any) {
        var phNumber: String
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: "(", with: ""))!
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: ")", with: ""))!
        phNumber = (currentSupportGroup?.contact!.replacingOccurrences(of: " ", with: ""))!
        guard let number = URL(string: "telprompt://" + phNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func emailSupportGroup1(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func emailSupportGroup2(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func websiteSupportGroup1(_ sender: Any) {
        self.isWebsite = true
        self.requestedURL = currentSupportGroup?.website!
        performSegue(withIdentifier: "ShowSupportWebDetailsSegue", sender: self)
    }
    
    @IBAction func websiteSupportGroup2(_ sender: Any) {
        self.isWebsite = true
        self.requestedURL = currentSupportGroup?.website!
        performSegue(withIdentifier: "ShowSupportWebDetailsSegue", sender: self)
    }
    
    @IBAction func locationSupportGroup1(_ sender: Any) {
        self.isWebsite = false
        self.requestedURL = currentSupportGroup?.mapsURL!
        performSegue(withIdentifier: "ShowSupportWebDetailsSegue", sender: self)
    }
    
    @IBAction func locationSupportGroup2(_ sender: Any) {
        self.isWebsite = false
        self.requestedURL = currentSupportGroup?.mapsURL!
        performSegue(withIdentifier: "ShowSupportWebDetailsSegue", sender: self)
    }
    
    
    func assignLabels()
    {
        self.callTextButton.contentHorizontalAlignment = .left
        self.emailTextButton.contentHorizontalAlignment = .left
        self.websiteTextButton.contentHorizontalAlignment = .left
        self.locationTextButton.contentHorizontalAlignment = .left
        
        self.labelName.text = currentSupportGroup?.name
        let address: String
        address = "\(String(describing: (currentSupportGroup?.address!)!)), \(String(describing: (currentSupportGroup?.suburb!)!)), \(String(describing: (currentSupportGroup?.state!)!)) - \(String(describing: (currentSupportGroup?.postcode!)!))"
        self.labelAddress.text = address
        self.callTextButton.setTitle(currentSupportGroup?.contact!, for: .normal)
        //        self.callTextButton.titleLabel?.text = currentSupportGroup?.contact
        
        if (currentSupportGroup?.email! == "")
        {
            // emailTextButton.isHidden = true
            //emailImageButton.isHidden = true
            emailTextButton.setTitle("Unavailable", for: .normal)
            emailTextButton.isEnabled = false
            emailImageButton.isEnabled = false
        }
        
        if (currentSupportGroup?.website! == "")
        {
            //websiteTextButton.isHidden = true
            //websiteImageButton.isHidden = true
            websiteTextButton.setTitle("Unavailable", for: .normal)
            websiteTextButton.isEnabled = false
            websiteTextButton.isEnabled = false
        }
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            print(currentSupportGroup)
            mail.setToRecipients([(currentSupportGroup?.email)!])
            mail.setSubject("Support Group Information")
            mail.setMessageBody("<p>Hi, </p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowSupportWebDetailsSegue")
        {
            let destinationVC: SupportGroupWebDetailsViewController = segue.destination as! SupportGroupWebDetailsViewController
            destinationVC.urlToLoad = self.requestedURL
            destinationVC.isWebsite = self.isWebsite
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
