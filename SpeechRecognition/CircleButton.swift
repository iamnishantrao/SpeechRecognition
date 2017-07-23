//
//  CircleButton.swift
//  SpeechRecognition
//
//  Created by Nishant on 23/07/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

// class to make button circular in shape
@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        
        didSet {
            
            setUpView()
        }
    }
    
    // function to display button shape in the InterfaceBuilder
    override func prepareForInterfaceBuilder() {
        
        setUpView()
    }
    
    func setUpView() {
        
        layer.cornerRadius = cornerRadius
    }

}
