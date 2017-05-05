//
//  AudioRecorderManager.swift
//  AudioRecorder
//
//  Created by Vincent Liu on 5/5/17.
//  Copyright © 2017 Vincent Liu. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class AudioRecorderManager: NSObject{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let shared = AudioRecorderManager()
    
    
    
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder?
    
    func setup()
    {
        recordingSession = AVAudioSession.sharedInstance()
        
        
        do
        {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission({ (allowed: Bool) in
                if allowed {
                    print("Mic authorized")
                }
                else{
                    print("Mic not authorized")
                }
                
            })
        }catch{
            print("failed to set category", error.localizedDescription)
        }
    }
    
    var meterTimer: Timer?
    
    var recorderApc0:Float = 0
    var recorderPeak0:Float = 0
    var audioLocalURL: String?
    //Start the record session
    func recored(fileName: String) -> Bool
    {
        
        setup()
        
        let url = getUserPath().appendingPathComponent(fileName+".m4a")
        
        let audioURL = URL.init(fileURLWithPath: url.path)
        
        self.audioLocalURL = audioURL.absoluteString
        
        let recoredSettings:[String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 12000.0,
            AVNumberOfChannelsKey:1,
            AVSampleRateKey:44100.0
        ]
        
        do{
            recorder = try AVAudioRecorder(url: audioURL, settings: recoredSettings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            
            recorder?.record()
            
            //            Timer.scheduledTimer(timeInterval: 1.0, target:appDelegate, selector: #selector(appDelegate.testTimer), userInfo: nil, repeats: true)
            
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: "testTimer", userInfo: nil, repeats: true)
            
            //            self.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block:{ (timer: Timer) in
            //
            //                //Here we should always update the recorder meter values so we can track the voice loudness
            //                if let recorder = self.recorder{
            //
            //                    recorder.updateMeters()
            //                    self.recorderApc0 = recorder.averagePower(forChannel: 0)
            //                    self.recorderPeak0 = recorder.peakPower(forChannel: 0)
            //                }
            //
            //            })
            
            
            print("Recording")
            
            return true
        }catch {
            print("Error recording")
            self.audioLocalURL = nil
            return false
        }
        
    }
    
    func testTimer()
    {
        print("asda")
        if let recorder = self.recorder{
            recorder.updateMeters()
            self.recorderApc0 = recorder.averagePower(forChannel: 0)
            self.recorderPeak0 = recorder.peakPower(forChannel: 0)
        }
    }
    
    //stop the recorder
    func finishRecording()
    {
        self.recorder?.stop()
        self.meterTimer?.invalidate()
    }
    
    //get the path for the folder we will be saving the file to
    func getUserPath() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Manager did finish recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error encoding", error?.localizedDescription ?? "")
    }
}





















