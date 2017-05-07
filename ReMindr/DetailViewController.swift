//
//  DetailViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 7/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

protocol Table3Delegate
{
    func detailVCDismissed()
}

protocol failedDelete {
    func failDelete()
}
class DetailViewController: UIViewController, AVAudioPlayerDelegate{

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var photoTitleLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteAction(_ sender: Any) {
        
        showInputDialog()
        

    }
    
    
    var image: UIImage!
    
    var photoTitle: String!
    
    var playButton: UIButton!
    var stopButton: UIButton!
    var audioPlayer: AVAudioPlayer!
    var audioURL: String?
    var delegate: Table3Delegate?
    var failDeleteDelegate: failedDelete?
    var delete: Bool?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("executed")
        playButton = UIButton(frame: CGRect(x: 110, y: 500, width: 150, height: 64))
        playButton.isHidden = false
        let playImage = resizeImage(image: UIImage(named: "play")!, newWidth: CGFloat(60))
        playButton.setImage(playImage, for: .normal)
        playButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        stopButton = UIButton(frame: CGRect(x: 110, y: 500, width: 150, height: 64))
        stopButton.isHidden = true
    }
    
    
   
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully
        flag: Bool) {
        print("Finished")
        let playImage = resizeImage(image: UIImage(named: "play")!, newWidth: CGFloat(60))
        playButton.setImage(playImage, for: .normal)
        stopButton.isHidden = true
        playButton.isHidden = false
        
    }
    
    func buttonPressed() {
        print("hello")
        print(audioURL)
        
        //        if audioRecorder!.isRecording == false {
        let stopImage = resizeImage(image: UIImage(named: "stop")!, newWidth: CGFloat(30))
        stopButton = UIButton(frame: CGRect(x: 110, y: 500, width: 150, height: 64))
        stopButton.setImage(stopImage, for: .normal)
        playButton.isHidden = true
        stopButton.isHidden = false
        //            recordButton.isEnabled = false
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        self.view.addSubview(stopButton)
        
        let urlstring = audioURL
        let url = URL(string: urlstring!)
        
        
        weak var weakSelf = self
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url! as URL, completionHandler: { (URL, response, error) -> Void in
            
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: URL!)
                self.audioPlayer!.delegate = self
                self.audioPlayer!.prepareToPlay()
                self.audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
            
            
        })
        
        downloadTask.resume()

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
    
    func stopTapped(){
        print("Stopped")
        if(audioPlayer != nil)
        {
            audioPlayer!.stop()
            print("Clicked stopped")
        }
        stopButton.isHidden = true
        playButton.isHidden = false
        //        recordButton.isEnabled = true
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        photoTitleLabel.text = photoTitle
        
        self.view.addSubview(playButton)
        navigationItem.title = "Photo Details"
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedMe))
//        imageView.addGestureRecognizer(tap)
//        imageView.isUserInteractionEnabled = true
    }
    
    func tappedMe()
    {
        showInputDialog()
    }
    
    
    
    func showInputDialog(){
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Delete Warning", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let ref = FIRDatabase.database().reference().child("Photos").child(AppDelegate.GlobalVariables.patientID)
            //let ref = FIRDatabase.database().reference().child("Photos").child("testpatient")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                
                for current in snapshot.children.allObjects as! [FIRDataSnapshot]
                {
                    let value = current.value as? NSDictionary
                    let photoDesc = value?["Description"] as! String
                    let onlineaudioURL = value?["audioURL"] as! String
                    if photoDesc != "this is a sample photo"
                    {
                        if onlineaudioURL == self.audioURL
                        {
                            current.ref.removeValue()
                            self.delegate?.detailVCDismissed()
                            
                            return
                        }
                    }
                    else{
                        self.failDeleteDelegate?.failDelete()
                    }
                    
                    
                    
                }
                
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.navigationController?.popViewController(animated: true)
            
            
            
   }
        
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.delete = false
            
//            alertController.dismiss(animated: true, completion: nil)
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
   
    
}

extension DetailViewController : ZoomingViewController
{
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return imageView
    }
}
