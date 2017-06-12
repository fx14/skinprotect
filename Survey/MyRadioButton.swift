//
//  MyRadioButton.swift
//  Survey
//
//  Created by Charles Balachandran on 13/03/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation
import UIKit

class MyRadioButton : UIButton {
//    var myAlternateButton:Array<MyRadioButton>?
    var myAlternateButton:[MyRadioButton] = []
    
    
    var selectStateImage:String? {
        didSet {
            if selectStateImage != nil {
//                self.setImage(UIImage(named: selectStateImage!), forState: UIControlState.Selected)
                let titleButton = self.titleLabel?.text
                //            radioButton.titleLabel?.adjustsFontSizeToFitWidth = true
                self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                self.set(image: UIImage(named: selectStateImage!), title: titleButton, titlePosition: .Right, additionalSpacing: 100.0, state: .Selected)
            }
        }
    }
    
    var unselectStateImage:String?{
        didSet {
            if unselectStateImage != nil {
//                self.setImage(UIImage(named: unselectStateImage!), forState: UIControlState.Normal)
                let titleButton = self.titleLabel?.text
                self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                self.set(image: UIImage(named: unselectStateImage!), title: titleButton, titlePosition: .Right, additionalSpacing: 100.0, state: .Normal)
            }
        }
    }
    
    func unselectAlternateButtons(){
        if myAlternateButton.count != 0 {
            self.selected = true
            for aButton:MyRadioButton in myAlternateButton {
                aButton.selected = false
            }
        } else {
            toggleButton()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        unselectAlternateButtons()
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    
    func toggleButton(){
        if self.selected == false {
            self.selected = true
        } else {
            self.selected = false
        }
    }
}