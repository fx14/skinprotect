//
//  InfoViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 05/04/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import CoreData

class InfoViewController: UIViewController {
    
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let w = UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 10
    let h = UIScreen.mainScreen().bounds.height / 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height)
        // set title screen
        self.title = NSLocalizedString("terms_controller_title", comment: "Terms and Condition")
        
        let image = UIImage(named:"home.png") as UIImage!
        var btnBack:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btnBack.addTarget(self, action: "homeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(image, forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        loadTermsCondition()
    }
    
    @IBAction func homeButtonPressed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    private func loadTermsCondition() {
        var posY = screenSize.height / 100
        var posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
        
        var ethLogo = UIImageView(frame: CGRectMake(posX, posY, w, h/2))
        ethLogo.image = UIImage(named: "eth_logo.png")
        distance = posY + ethLogo.frame.height + 10
        scrollView.addSubview(ethLogo)
        
        var qLabel: UILabel = UILabel()
        qLabel.frame = CGRectMake(posX, distance, w, h)
        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        qLabel.numberOfLines = 20
        qLabel.textColor = UIColor.blackColor()
        qLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        qLabel.textAlignment = NSTextAlignment.Justified
        qLabel.text = NSLocalizedString("terms_condition_header", comment: "Terms and Condition")
        qLabel.adjustsFontSizeToFitWidth = true
        qLabel.sizeToFit()
        scrollView.addSubview(qLabel)
        distance += posY + qLabel.frame.height + 10
        
        var pointOne: UILabel = UILabel()
        pointOne.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointOne.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointOne.numberOfLines = 9
        pointOne.textColor = UIColor.blackColor()
        //        pointOne.backgroundColor = UIColor.redColor()
        pointOne.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointOne.textAlignment = NSTextAlignment.Justified
        pointOne.text = NSLocalizedString("point_one", comment: "Point One")
        pointOne.adjustsFontSizeToFitWidth = true
        pointOne.sizeToFit()
        scrollView.addSubview(pointOne)
        
        distance += pointOne.frame.height + 10
        var pointTwo: UILabel = UILabel()
        pointTwo.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointTwo.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointTwo.numberOfLines = 9
        pointTwo.textColor = UIColor.blackColor()
        //        pointTwo.backgroundColor = UIColor.redColor()
        pointTwo.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointTwo.textAlignment = NSTextAlignment.Justified
        pointTwo.text = NSLocalizedString("point_two", comment: "Point Two")
        pointTwo.adjustsFontSizeToFitWidth = true
        pointTwo.sizeToFit()
        scrollView.addSubview(pointTwo)
        
        distance += pointTwo.frame.height + 10
        var pointThree: UILabel = UILabel()
        pointThree.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointThree.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointThree.numberOfLines = 9
        pointThree.textColor = UIColor.blackColor()
        //        pointTwo.backgroundColor = UIColor.redColor()
        pointThree.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointThree.textAlignment = NSTextAlignment.Justified
        pointThree.text = NSLocalizedString("point_three", comment: "Point One")
        pointThree.adjustsFontSizeToFitWidth = true
        pointThree.sizeToFit()
        scrollView.addSubview(pointThree)
        
        distance += pointThree.frame.height + 10
        var pointFour: UILabel = UILabel()
        pointFour.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointFour.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointFour.numberOfLines = 9
        pointFour.textColor = UIColor.blackColor()
        //        pointTwo.backgroundColor = UIColor.redColor()
        pointFour.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointFour.textAlignment = NSTextAlignment.Justified
        pointFour.text = NSLocalizedString("point_four", comment: "Point One")
        pointFour.adjustsFontSizeToFitWidth = true
        pointFour.sizeToFit()
        scrollView.addSubview(pointFour)
        
        distance += pointFour.frame.height + 10
        var pointFive: UILabel = UILabel()
        pointFive.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointFive.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointFive.numberOfLines = 9
        pointFive.textColor = UIColor.blackColor()
        //        pointTwo.backgroundColor = UIColor.redColor()
        pointFive.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointFive.textAlignment = NSTextAlignment.Justified
        pointFive.text = NSLocalizedString("point_five", comment: "Point One")
        pointFive.adjustsFontSizeToFitWidth = true
        pointFive.sizeToFit()
        scrollView.addSubview(pointFive)
        
        distance += pointFive.frame.height + 10
        var pointSix: UILabel = UILabel()
        pointSix.frame = CGRectMake(posX, distance, w, UIScreen.mainScreen().bounds.height / 7)
        pointSix.lineBreakMode = NSLineBreakMode.ByWordWrapping
        pointSix.numberOfLines = 9
        pointSix.textColor = UIColor.blackColor()
        //        pointTwo.backgroundColor = UIColor.redColor()
        pointSix.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        pointSix.textAlignment = NSTextAlignment.Justified
        pointSix.text = NSLocalizedString("point_six", comment: "Point One")
        pointSix.adjustsFontSizeToFitWidth = true
        pointSix.sizeToFit()
        scrollView.addSubview(pointSix)
        distance += pointSix.frame.height + 10
        
        // Add accept button only if the conditions are not still accepted
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Configuration")
        fReq.returnsObjectsAsFaults = false
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        let resultItem = result![0] as! Configuration
        if (resultItem.terms_accepted == "0") {
            var acceptButton = UIButton(frame: CGRectMake(posX, distance, w, 40))
            acceptButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
            
            acceptButton.setTitle(NSLocalizedString("accept", comment: "Accept"), forState: UIControlState.Normal)
            acceptButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
            acceptButton.addTarget(self, action:"acceptButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            scrollView.addSubview(acceptButton)
            distance += acceptButton.frame.height + 10
        }
        
        scrollView.contentSize = CGSizeMake(screenSize.width, distance + 20)
        
//        scrollView.layer.shadowColor = UIColor.blackColor().CGColor
//        scrollView.layer.shadowOffset = CGSizeZero
//        scrollView.layer.shadowOpacity = 0.5
//        scrollView.layer.shadowRadius = 5
        
        scrollView.layer.cornerRadius = 10.0
        scrollView.layer.borderColor = UIColor.grayColor().CGColor
        scrollView.layer.borderWidth = 0.5
        scrollView.clipsToBounds = true
    }
    
    func acceptButtonPressed(sender:UIButton) {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue("1", forKey: "terms_accepted")
                managedObjectContext!.save(nil)
            }
        }

        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
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