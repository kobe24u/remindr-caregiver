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
import AudioToolbox

protocol Table2Delegate: NSObjectProtocol {
    func table2WillDismissed()
}

class photoInfoViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate {

    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var chosenImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoDescTextfield: UITextField!
    
    @IBOutlet weak var recoredView: UIView!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var micBtn: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelLabel: UIButton!
    var chosenImage: UIImage?
    var imageURL: String?
    var audioURL: String?
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioLocalURL: String?
    var imageUUID: String?
    
    @IBOutlet weak var savingLabel: UILabel!
    
    var nonObservablePropertiesUpdateTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    weak var del: Table2Delegate?
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
  

    @IBAction func playFile(_ sender: Any) {
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
    
    
    
    @IBAction func StartRecording(_ sender: UIButton) {
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        if AudioRecorderManager.shared.recored(fileName: "TestFile")
        {
            nonObservablePropertiesUpdateTimer.resume()
        }
        
        //we need to create a date formatter to format the time from the recorder
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.minute, .second]
        formatter.calendar = Calendar.current
        
        nonObservablePropertiesUpdateTimer.setEventHandler { [weak self] in
            //Audio recording circle animations here
            
            guard let peak = AudioRecorderManager.shared.recorder else{
                return
            }
            
            print(AudioRecorderManager.shared.recorder!.currentTime)
            
            self?.durationLabel.text = formatter.string(from: AudioRecorderManager.shared.recorder!.currentTime)
            
            let percent = (Double(AudioRecorderManager.shared.recorderPeak0) + 160) / 160
            
            let final = CGFloat(percent) + 0.3
            
            UIView.animate(withDuration: 0.15, animations: {
                self!.WaveAnimationView.transform = CGAffineTransform(scaleX: final, y: final)
            })
            
        }
        
        nonObservablePropertiesUpdateTimer.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(100))
        
        
        
        
        UIView.animate(withDuration: 0.15, animations: {
            self.WaveAnimationView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Release to stop recording"
            self.statusLabel.textColor = UIColor.orange
        }
    }
    
    
    @IBAction func stopRecording(_ sender: UIButton) {
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        AudioRecorderManager.shared.finishRecording()
        if (AudioRecorderManager.shared.audioLocalURL != nil)
        {
            self.audioLocalURL = AudioRecorderManager.shared.audioLocalURL
        }
        
        playBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        nonObservablePropertiesUpdateTimer.suspend()
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Press again to record a new audio message"
            self.statusLabel.textColor = UIColor.red
        }
    }
    
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc  = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionView") as! PhotoCollectionViewController
        
        self.present(vc, animated: true, completion: nil)
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
                self.recoredView.isHidden = true
                self.statusLabel.isHidden = true
                
                self.savingLabel.isHidden = false
                
                self.savingLabel.text = "Storing into server...."
                self.savingLabel.textColor = UIColor.white
                self.saveButton.isHidden = true
                self.cancelLabel.isHidden = true
                self.micBtn.isHidden = true
                self.playBtn.isHidden = true
                self.WaveAnimationView.isHidden = true
                self.titleLabel.isHidden = true
                
                
                self.view.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
                activityView.color = UIColor.black
                activityView.center = self.view.center
                self.view.addSubview(activityView)
                activityView.startAnimating()
                
                
                let imageName = NSUUID().uuidString
                self.imageUUID = imageName
                let storageRef = FIRStorage.storage().reference().child("added_photos").child("\(imageName).png")
                
                var vc: PhotoCollectionViewController?
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
                        
                        self.del?.table2WillDismissed()
                        self.dismiss(animated: true, completion: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let vc  = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionView") as! PhotoCollectionViewController
                        
                        self.present(vc, animated: true, completion: nil)
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                        
                    
                    })
                
                }
            }
        }
   
        
    }
    
    var WaveAnimationView:UIView!
    func buildVoiceCirlce(){
        
        let size = CGSize(width: 200, height: 200)
        
        let newPoint = CGPoint(x:self.recoredView.frame.size.width / 2 - 100 , y: self.recoredView.frame.size.height / 2 - 100)
        WaveAnimationView = UIView(frame: CGRect(origin:newPoint , size: size))
        WaveAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        WaveAnimationView.layer.cornerRadius = 100
        WaveAnimationView.backgroundColor = UIColor.clear
        WaveAnimationView.layer.borderColor = UIColor.red.cgColor
        WaveAnimationView.layer.borderWidth = 1.0
        self.recoredView.addSubview(WaveAnimationView)
        
        self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        saveButton.backgroundColor = .clear
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.black.cgColor
        
          cancelLabel.backgroundColor = .clear
        cancelLabel.layer.cornerRadius = 5
        cancelLabel.layer.borderWidth = 1
        cancelLabel.layer.borderColor = UIColor.black.cgColor
        
        
        
        photoDescTextfield.returnKeyType = .done
    
        
        hideKeyboard()
        playBtn.isHidden = true
        
        self.buildVoiceCirlce()
        
        savingLabel.isHidden = true
        
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
    
    func promptMessage2(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1
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
    
    
    

  
    
    
    
}
