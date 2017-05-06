//
//  InitialQRScanViewController.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 6/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

/*
 Source: AppCoda
 Retrieved from: http://www.appcoda.com/qr-code-reader-swift/
 */

import UIKit
import AVFoundation
import Firebase

class InitialQRScanViewController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var successView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var textPatientName: UITextField!
    
    @IBOutlet weak var textPatientMobile: UITextField!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var patientDeviceUUID: String?
    var detected: Bool?
    var ref: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        self.detected = false
        self.successView.isHidden = true
        self.textPatientName.delegate = self
        self.textPatientMobile.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        successView.addGestureRecognizer(tap)
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textPatientName.endEditing(true)
        self.textPatientMobile.endEditing(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if (self.detected == false)
        {
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                self.detected = true
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if metadataObj.stringValue != nil {
                    self.patientDeviceUUID = metadataObj.stringValue
                    //messageLabel.text = metadataObj.stringValue
                    messageLabel.isHidden = true
                    writingDataToPList()
                    
                    showSuccessMessage()
                }
            }
        }
        
    }
    
    func writingDataToPList()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.appending("/data.plist")
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path)))
        {
            let bundle : NSString = Bundle.main.path(forResource: "data", ofType: "plist")! as NSString
            do{
                try fileManager.copyItem(atPath: bundle as String, toPath: path)
            }catch{
                print("copy failure.")
            }
        }
        let data : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
        data.setObject(self.patientDeviceUUID, forKey: "patientDeviceUUID" as NSCopying)
        let success: Bool = data.write(toFile: path, atomically: true)
        if (success)
        {
            print ("Success plist")
            AppDelegate.GlobalVariables.patientID = self.patientDeviceUUID!
        }
        else
        {
            print("Unsuccessful plist")
        }    }
    
    
    func showSuccessMessage()
    {
        
        //1015
        let systemSoundID: SystemSoundID = 1013
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.successView.isHidden = false
            self.view.bringSubview(toFront: self.successView)
            
        })
        
    }
    
    @IBAction func savePatientInformation(_ sender: Any) {
        var textName: String?
        var textMobile: String?
        
        textName = self.textPatientName.text
        textMobile = self.textPatientMobile.text
        
        print ("name and contact \(textName) \(textMobile)")
        
        if ((textName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (textMobile?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!)
        {
            displayAlertMessage(title: "Alert", message: "Name and mobile number are mandatory")
        }
        else
        {
            if (textMobile?.characters.count != 10)
            {
                displayAlertMessage(title: "Invalid number", message: "Please enter a 10 digit number (eg. 0401234567")
            }
            else
            {
                let username: String = self.patientDeviceUUID!
                let values: [String: Any]
                values = ["name": textName ?? "nil", "mobileNumber": textMobile ?? "nil", "username": username]
                ref?.child("patientContacts").child(username).setValue(values)
                performSegue(withIdentifier: "ShowMainScreenSegue", sender: self)
            }
        }
    }
    
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
    
        /*
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            
            //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //
            //            let vc  = storyboard.instantiateViewController(withIdentifier: "home") as! MainMenuViewController
            //
            //
            //
            //            let navController = UINavigationController(rootViewController: vc)
            //
            //            self.navigationController?.popToViewController(vc, animated: true)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
 */
    
}
