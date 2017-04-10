//
//  photoInfoViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 8/4/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

protocol Table2Delegate: NSObjectProtocol {
    func table2WillDismissed()
}

class photoInfoViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate {

    @IBOutlet weak var chosenImageView: UIImageView!
    
    @IBOutlet weak var photoDescTextfield: UITextField!
    
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var rerecordButton: UIButton!
    
    @IBOutlet weak var descLabel: UILabel!
    
    
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelLabel: UIButton!
    var chosenImage: UIImage?
    var imageURL: String?
    var audioURL: String?
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioLocalURL: String?
    var imageUUID: String?
    var recordingSession: AVAudioSession!
    
    weak var del: Table2Delegate?
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
  

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
                recordingSession = AVAudioSession.sharedInstance()
        
                do {
                    try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                    try recordingSession.setActive(true)
                    recordingSession.requestRecordPermission() { [unowned self] allowed in
                        
                    }
                } catch {
                    // failed to record!
                    print("failed to record")
                }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    @IBAction func checkBeforeSaveIntoDatabase(_ sender: Any) {
        
        
        let photoDesc = (photoDescTextfield.text)!
        if photoDesc.isEmpty
        {
            self.promptMessage(title: "Oops", message: "The description cannot be null")
            
        }
            else
        {
            if audioLocalURL == nil
            {
                self.promptMessage(title: "Oops", message: "You have not record an audio clip for the image")
            }
            else{
                self.chosenImageView.isHidden = true
                self.photoDescTextfield.isHidden = true
                self.playButton.isHidden = true
                self.stopButton.isHidden = true
                self.rerecordButton.isHidden = true
                self.descLabel.isHidden = true
                self.recordLabel.text = "Storing into server...."
                self.recordLabel.textColor = UIColor.white
                self.saveButton.isHidden = true
                self.cancelLabel.isHidden = true
                
                self.view.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
                activityView.color = UIColor.black
                activityView.center = self.view.center
                self.view.addSubview(activityView)
                activityView.startAnimating()
                
                
                let imageName = NSUUID().uuidString
                self.imageUUID = imageName
                let storageRef = FIRStorage.storage().reference().child("added_photos").child("\(imageName).png")
                
                if let uploadData = UIImagePNGRepresentation(self.chosenImage!) {
                    
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        if let imageUrl = metadata?.downloadURL()?.absoluteString {
                            self.imageURL = imageUrl
                            self.handleAudioSendWith(url: self.audioLocalURL!)
                        }
                        self.promptMessage(title: "Ta-da!", message: "You've successfully added a new photo")
                        self.del?.table2WillDismissed()
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
     
            }
        }
   
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        rerecordButton.isHidden = true
        
        chosenImageView.image = chosenImage
        
        photoDescTextfield.delegate = self

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    
    fileprivate func addPhotoIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("Photos").child("testpatient").child(uid)
    
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
        })
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudiFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent(".m4a")
    }
    
    func handleAudioSendWith(url: String) {
        guard let fileUrl = URL(string: url) else {
            return
        }
        let fileName = NSUUID().uuidString + ".m4a"
        
        FIRStorage.storage().reference().child("added_voices").child(fileName).putFile(fileUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "error")
            }
            
            if let downloadUrl = metadata?.downloadURL()?.absoluteString {
                print(downloadUrl)
                self.audioURL = downloadUrl
                let values = ["Description": self.photoDescTextfield.text, "photoURL": self.imageURL, "audioURL": self.audioURL]
                self.dismiss(animated: true, completion: nil)
                self.addPhotoIntoDatabaseWithUID(self.imageUUID!, values: values as [String : AnyObject])
            }
        }
    }
    
    
    
    @IBAction func startRecording(_ sender: Any) {
        
        if self.audioLocalURL == nil {
                        print("audioLocalURL nil")
                        startRecording()
                    }
                    else {
                        print("audioURLLocal not nil")
            if let url = URL(string: self.audioLocalURL!) {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.delegate = self
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                    print("Audio ready to play")
                } catch let error {
                    print(error.localizedDescription)
                }
            }
                    }
    
    }
    
    func startRecording()
    {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            let audioFileUrl = getAudiFileURL()
            self.audioLocalURL = audioFileUrl.absoluteString
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            playButton.isHidden = true
            stopButton.isHidden = false
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
                audioRecorder.stop()

                if success {
                    playButton.isHidden = false
                    playButton.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
                    rerecordButton.isHidden = false
   
                } else {
                    print("record_failed")
                }
            }

    
    
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        if audioRecorder.isRecording == true
        {
            stopButton.isHidden = true
            finishRecording(success: true)
        }

    }
    
    
    @IBAction func rerecordButtonTapped(_ sender: Any) {
        startRecording()
    }
    
    
    
}
