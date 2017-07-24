//
//  MainVC.swift
//  SpeechRecognition
//
//  Created by Nishant on 23/07/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class MainVC: UIViewController, SFSpeechRecognizerDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var transcribedText: UITextView!
    
    @IBOutlet weak var redActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var greenActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var redButton: CircleButton!
    @IBOutlet weak var greenButton: CircleButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var urlRequest: SFSpeechURLRecognitionRequest!
    private var audioRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    
    private var audioPlayer: AVAudioPlayer!
    
    private var audioEngine =  AVAudioEngine()
    
    private var liveAudio: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        redActivityIndicator.isHidden = true
        greenActivityIndicator.isHidden = true
        
        redButton.isEnabled = false
        greenButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.speechRecognizer.delegate = self
        
        // Request Speech Authorization.
        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            // Handle various cases for Speech Authorization.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.redButton.isEnabled = true
                    self.greenButton.isEnabled = true
                    
                case .denied:
                    self.redButton.isEnabled = false
                    self.greenButton.isEnabled = false
                    print("User denied access to speech recognition")
                    
                case .restricted:
                    self.redButton.isEnabled = false
                    self.greenButton.isEnabled = false
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    self.redButton.isEnabled = false
                    self.greenButton.isEnabled = false
                    print("Speech recognition not yet authorized")
                }
            }
        }

    }

    // Transcribe recorded audio.
    @IBAction func redButtonPressed(_ sender: Any) {
        
        redActivityIndicator.isHidden = false
        redActivityIndicator.startAnimating()
        
        if let path = Bundle.main.url(forResource: "test", withExtension: "m4a") {
            
            do {
                
                let sound = try AVAudioPlayer(contentsOf: path)
                self.audioPlayer = sound
                self.audioPlayer.delegate = self
                sound.play()
                
            } catch {
                
                print("Error occured!")
            }
            
            // check if speech recognition is not available currently
            // speech recognition may not be available due to current internet availability
            if !speechRecognizer.isAvailable {
                
                print("Speech Recognition is not available currently.")
                return
            }
            
            self.urlRequest = SFSpeechURLRecognitionRequest(url: path)
            
            speechRecognizer.recognitionTask(with: urlRequest!) { (result, error) in
                
                guard let result = result else {
                    
                    print("There was an error: \(String(describing: error))")
                    return
                }
                
                if result.isFinal {
                    
                    print(result.bestTranscription.formattedString)
                    self.transcribedText.text = result.bestTranscription.formattedString
                    
                }
                
            }
        }
    }
    
    // Transcribe live audio.
    // Throws is used to handle errors throws by audioSession.
    @IBAction func greenButtonPressed(_ sender: Any) {
        
        greenActivityIndicator.isHidden = false
        greenActivityIndicator.startAnimating()
        
        if audioEngine.isRunning {
            
            audioEngine.stop()
            audioRequest.endAudio()
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
     
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
        } catch {
            
            print("Error occurred while setting Audio Session.")
        }
        
        audioRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            
            fatalError("Audio engine has no input node.")
        }
        
        guard let audioRequest = audioRequest else {
            
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // Configure request so that results are returned before audio recording is finished
        audioRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: audioRequest) { (result, error) in
            
            var isFinal = false

            if let result = result {

                self.transcribedText.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            if error != nil || isFinal {

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.audioRequest = nil
                self.recognitionTask = nil

                self.greenButton.isEnabled = true

            }

            let recordingFormat = inputNode.inputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in

                self.audioRequest?.append(buffer)
            }

            self.audioEngine.prepare()
            
            do {
                
                try self.audioEngine.start()

            } catch {
                
                print("Error occurred while starting Audio Engine.")
            }

        }
    }
    
    // function to analyze when AVAudioPlayer has finished playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        player.stop()
        redActivityIndicator.stopAnimating()
        redActivityIndicator.isHidden = true
    }
    
}

