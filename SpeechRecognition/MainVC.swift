//
//  MainVC.swift
//  SpeechRecognition
//
//  Created by Nishant on 23/07/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var transcribedText: UITextView!
    @IBOutlet weak var redActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var greenActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // Transcribe recorded audio.
    @IBAction func redButtonPressed(_ sender: Any) {
        
        
    }
    
    // Transcribe live audio.
    @IBAction func greenButtonPressed(_ sender: Any) {
        
        
    }
    
}

