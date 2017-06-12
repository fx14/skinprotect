//
//  AppQuestionController.swift
//  Survey
//
//  Created by Charles Balachandran on 07/04/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class AppQuestionController: UIViewController {
    
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let w = UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 10
    let h = UIScreen.mainScreen().bounds.height / 6
    
    private var acceptButton = UIButton()
    private var selectedValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height)
        // set title screen
        self.title = NSLocalizedString("about_app", comment: "About App")

        loadRadioButtonQuestion()
    }
    
    private func generateLabel(title: String, xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UILabel {
        var qLabel: UILabel = UILabel()
        qLabel.frame = CGRectMake(xPosition, yPosition, width, height)
        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        qLabel.numberOfLines = 3
        qLabel.backgroundColor = UIColor.orangeColor()
        qLabel.textColor = UIColor.whiteColor()
        qLabel.adjustsFontSizeToFitWidth = true
        qLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        qLabel.textAlignment = NSTextAlignment.Center
        qLabel.text = title
        
        
        qLabel.layer.shadowColor = UIColor.blackColor().CGColor
        qLabel.layer.shadowOffset = CGSizeZero
        qLabel.layer.shadowOpacity = 0.5
        qLabel.layer.shadowRadius = 5
        
        qLabel.layer.cornerRadius = 10.0
        qLabel.layer.borderColor = UIColor.grayColor().CGColor
        qLabel.layer.borderWidth = 0.5
        qLabel.clipsToBounds = true
        return qLabel
    }
    
    
    // Radio button question generator (1)
    private func loadRadioButtonQuestion() {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
        let txt = NSLocalizedString("app_find_question", comment: "Where did you find the app?")
        scrollView.addSubview(generateLabel(txt, xPosition: posX, yPosition: posY, width: w, height: h))
        
        // radio buttons
        var possibleChoices = [NSLocalizedString("news_paper", comment: "News Paper"),
            NSLocalizedString("questionaire_paper", comment: "Questionaire Paper"),
            NSLocalizedString("friends", comment: "Friends"),
            NSLocalizedString("social_media", comment: "Social Media"),
            NSLocalizedString("other", comment: "Other")]
        var radioButtons:[MyRadioButton] = []
        distance = posY + h
        
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        // create radiobuttons from number of answers
        for var i = 0; i < possibleChoices.count; i++ {
            distance += 10
            var radioButton = MyRadioButton(frame: CGRectMake(posX, distance, w/1.5 , screenSize.height/14))
            radioButtons.append(radioButton)
            radioButton.setTitle(possibleChoices[i], forState: UIControlState.Normal)
            radioButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingHead
            radioButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            radioButton.setTitleColor(UtilityClass.uiColorFromHex(0xfc6c5f), forState: UIControlState.Selected)
            radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            radioButton.titleLabel?.numberOfLines = 3
            radioButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            scrollView.addSubview(radioButton)
            
            radioButton.addTarget(self, action:"radioButtonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
            radioButton.selectStateImage = "radiobutton-checked.png";
            radioButton.unselectStateImage = "radiobutton-unchecked.png";
            distance += 45
            
        }
        
        // in case of button press, set other button to normal state
        for var i = 0; i < radioButtons.count; i++ {
            for var j = 0; j < radioButtons.count; j++ {
                if i != j {
                    radioButtons[i].myAlternateButton.append(radioButtons[j])
                }
            }
        }
        
        acceptButton = UIButton(frame: CGRectMake(posX, distance, w, 40))
        acceptButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        
        acceptButton.setTitle(NSLocalizedString("next", comment: "Next"), forState: UIControlState.Normal)
        acceptButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        acceptButton.addTarget(self, action:"nextButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(acceptButton)
        distance = distance + acceptButton.frame.height + 10
        acceptButton.enabled = false
        
        scrollView.contentSize = CGSizeMake(screenSize.width, distance + h)
        
        acceptButton.layer.shadowColor = UIColor.blackColor().CGColor
        acceptButton.layer.shadowOffset = CGSizeZero
        acceptButton.layer.shadowOpacity = 0.5
        acceptButton.layer.shadowRadius = 5
        
        acceptButton.layer.cornerRadius = 8.0
        acceptButton.layer.borderColor = UIColor.grayColor().CGColor
        acceptButton.layer.borderWidth = 0.5
        acceptButton.clipsToBounds = true
    }
    
    func radioButtonSelected(sender:MyRadioButton) {
        if let text = sender.titleLabel?.text {
            selectedValue = text
            acceptButton.enabled = true
        }
    }
    
    func nextButtonPressed(sender:UIButton) {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue(selectedValue, forKey: "app_found_from")
                managedObject.setValue("1", forKey: "app_question")
                managedObject.setValue(UIDevice.currentDevice().identifierForVendor.UUIDString, forKey: "app_identifier")
                managedObjectContext!.save(nil)
//                println(UIDevice.currentDevice().identifierForVendor.UUIDString)
            }
        }
        
        if selectedValue == NSLocalizedString("questionaire_paper", comment: "Questionaire Paper") {
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ScanIdentifier")
            self.showViewController(vc as! UIViewController, sender: vc)
        } else {
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
}