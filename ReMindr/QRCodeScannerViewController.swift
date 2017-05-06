//
//  QRCodeScannerViewController.swift
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

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var patientDeviceUUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.successView.isHidden = true
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
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
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
    
    func writingDataToPList()
    {
        let plistPath:String? = Bundle.main.path(forResource: "data", ofType: "plist")! //the path of the data
        let plistDictionary = NSMutableDictionary(contentsOfFile: plistPath!)
        
        do{
            // Reading the UUID of the device
            self.patientDeviceUUID = UIDevice.current.identifierForVendor!.uuidString
            plistDictionary?.setObject(self.patientDeviceUUID, forKey: "patientDeviceUUID" as NSCopying)
            var success: Bool = (plistDictionary?.write(toFile: plistPath!, atomically: true))!
            if success
            {
                print ("Successfully wrote to data.plist")
            }
            else
            {
                print ("Writing to data.plist unsuccessful")
            }
        }
        catch{ // error condition
            print("Error writing to plist: \(error)")
        }
    }
    
    
    func showSuccessMessage()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.successView.isHidden = false
            self.view.bringSubview(toFront: self.successView)
        }, completion: {(success: Bool) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
