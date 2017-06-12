
//
//  MainViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 16/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//


import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundOne: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    var popUpView: UIView = UIView()
    
    // background iamges
    private let images = [
        UIImage(named:"imageBackground.png")!,
        UIImage(named:"imageBackground1.png")!,
        UIImage(named:"imageBackground2.png")!,
        UIImage(named:"imageBackground5.png")!,
        UIImage(named:"imageBackground3.png")!,
        UIImage(named:"imageBackground4.png")!]
    
    
    // texts related to background images
    private let texts = [NSLocalizedString("scan_product_slide", comment: "Scan a product"),
        NSLocalizedString("household_product_slide", comment: "Household Products"),
        NSLocalizedString("personal_care_product_slide", comment: "Personal care products"),
        NSLocalizedString("make_up_product_slide", comment: "Make Up products"),
        NSLocalizedString("how_much_slide", comment: "How much?"),
        NSLocalizedString("how_often_slide", comment: "How Often?")]
    
    // animation variables
    private var index = 0
    private let animationDuration: NSTimeInterval = 1.5
    private let switchingInterval: NSTimeInterval = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // set button text based on language
        startBtn.setTitle( NSLocalizedString("start", comment: "Starting process button"), forState: UIControlState.Normal)
        startBtn.showsTouchWhenHighlighted = true
        backgroundOne.image = images[index]
        animateImageView()
        backgroundOne.contentMode = .ScaleAspectFit
        
        // Configure localDatabase
        configureDatabae()
        
        // load terminal and conditions
        loadTerminalAndCondition()
        
    }
    

        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    // Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // animate background image
    func animateImageView() {
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(self.switchingInterval * NSTimeInterval(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.animateImageView()
            }
        }
        
        let transition = CATransition()
        transition.type = kCATransitionFade
        
        backgroundOne.layer.addAnimation(transition, forKey: kCATransition)
        backgroundOne.image = images[index]
        
        textLabel.layer.addAnimation(transition, forKey: kCATransition)
        textLabel.text = texts[index];
        
        CATransaction.commit()
        
        index = index < images.count - 1 ? index + 1 : 0
    }
    
    private func configureDatabae() {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Configuration")
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        
        // for the first launch the result will be empty so we need to set "personal_question" to 0
        // result 0 means first launch
        if result?.count < 1 {
            var conf = NSEntityDescription.insertNewObjectForEntityForName("Configuration",
                inManagedObjectContext: managedObjectContext!) as! Configuration
            conf.terms_accepted = "0"
            conf.product_question = "0"
            conf.personal_question = "0"
            conf.app_question = "0"
            conf.id = "main_config"
            
            var error : NSError? = nil
            if !managedObjectContext!.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
            result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        }
        
        
        // If still there are no value for personalized question then its an error
        if result?.count < 1 {
            println("ERROR in MainViewController: no configuration found for personal question")
        }
    }
    
    private func isAppQuestionReplied() -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Configuration")
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        let resultItem = result![0] as! Configuration
        if (resultItem.app_question == "0") {
            return false
        }
        return true
    }
    
    private func isTermsAccepted() -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Configuration")
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        let resultItem = result![0] as! Configuration
        if (resultItem.terms_accepted == "0") {
            return false
        }
        return true
    }
    
    private func loadTerminalAndCondition() {
        if (!isTermsAccepted()) {
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("InfoViewController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    private func loadAppQuestionController() {
        if !isAppQuestionReplied() {
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("AppQuestionController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    
    
    
    /* Onclick Start button, check if the user has already done
    the personalized question, if yes skip to scan product
    otherwise ask user to do the personalized question */
    @IBAction func onClickStartBtn(sender: UIButton) {
        if !isTermsAccepted() {
            loadTerminalAndCondition()
        } else if !isAppQuestionReplied() {
            loadAppQuestionController()
        } else {
            // if internet is available
            if Reachability.isConnectedToNetwork() {
                let managedObjectContext = Singleton.sharedInstance.managedObjectContext
                var error: NSError? = nil
                var fReq: NSFetchRequest = NSFetchRequest(entityName: "Configuration")
                var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
                
                // load the personalized question
                let resultItem = result![0] as! Configuration
                
                // Load personal question
                if (resultItem.personal_question == "0") {
                    loadPersonalQuestionController(nil)
                    // Persoanl question done and not product question done
                } else if (resultItem.personal_question == "1" && resultItem.product_question == "0") {
                    let msg = NSLocalizedString("message_persoanl_question_done", comment: "Personal Question Done")
                    var alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.view.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
                    alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: self.resetQuestions))
                    alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: self.loadProductQuestionController))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else if (resultItem.personal_question == "1" && resultItem.product_question == "1") {
                    let msg = NSLocalizedString("message_persoan_product_question_done", comment: "Personal Product Done")
                    var alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.view.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
                    alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: self.resetQuestions))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
                
            } else {
                self.view.makeToast(message: NSLocalizedString("connect_to_internet", comment: "Please connect to the internet"))
            }
        }
    }
    
    
    // Reset personal question database and load personal question
    func resetQuestions(alert: UIAlertAction!) {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue("0", forKey: "personal_question")
                managedObject.setValue("0", forKey: "product_question")
                managedObjectContext!.save(nil)
            }
        }


        // Reset personal question datas
        Singleton.sharedInstance.answersPersonalQuetions.removeAllObjects()
        Singleton.sharedInstance.currentPersoalQNr = 0

        // Reset product question datas
        Singleton.sharedInstance.answersProductQuestions.removeAllObjects()
        Singleton.sharedInstance.currentProductsDetails = []
        Singleton.sharedInstance.doneProductQuestionPosition = 0
        Singleton.sharedInstance.doneProductQuestions = []
        
        // Load persoanl question
        loadPersonalQuestionController(nil)
    }
    
    //    func popUpView(alert: UIAlertAction!) {
    //        backgroundOne.alpha = 0.4
    //        startBtn.alpha = 0.4
    //        textLabel.alpha = 0.4
    //        startBtn.enabled = false
    //
    //        let screenSize: CGRect = UIScreen.mainScreen().bounds
    //        let posX = UIScreen.mainScreen().bounds.width / 10
    //        let w = UIScreen.mainScreen().bounds.width - 2*posX
    //        let h = UIScreen.mainScreen().bounds.height / 2
    //
    //        let posY = UIScreen.mainScreen().bounds.width / 2
    //        popUpView.frame = CGRectMake(posX, posY, w, h)
    //        popUpView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    //        popUpView.layer.cornerRadius = 5
    //        popUpView.layer.shadowOpacity = 0.8
    //        popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    //
    //
    //        var label: UILabel = UILabel(frame: CGRectMake(10, 10, w - 20, h/3))
    //        label.text = NSLocalizedString("select_type_product", comment: "select the product type")
    //        label.textColor = UIColor.whiteColor()
    //        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
    //        label.textAlignment = NSTextAlignment.Center
    //        label.adjustsFontSizeToFitWidth = true
    //
    //        var distance = h/5 + 10
    //        var houseHoldButton = UIButton(frame: CGRectMake(10, distance, w - 20, h/5))
    //        houseHoldButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
    //        houseHoldButton.setTitle(NSLocalizedString("household_pruducts", comment: "House Hold Products"), forState: UIControlState.Normal)
    //        houseHoldButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
    //        houseHoldButton.addTarget(self, action:"houseHoldButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    //        houseHoldButton.titleLabel?.adjustsFontSizeToFitWidth = true
    //
    //        distance += 10 + h/5
    //        var laundaryProductButton = UIButton(frame: CGRectMake(10, distance, w - 20, h/5))
    //        laundaryProductButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
    //        laundaryProductButton.setTitle(NSLocalizedString("laundry_product", comment: "Laundry Products"), forState: UIControlState.Normal)
    //        laundaryProductButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
    //        laundaryProductButton.addTarget(self, action:"laundaryButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    //        laundaryProductButton.titleLabel?.adjustsFontSizeToFitWidth = true
    //        distance += 10 + h/5
    //
    //        var personalProductButton = UIButton(frame: CGRectMake(10, distance, w - 20, h/5))
    //        personalProductButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
    //        personalProductButton.setTitle(NSLocalizedString("personal_care_product", comment: "Personal Care Products"), forState: UIControlState.Normal)
    //        personalProductButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
    //        personalProductButton.addTarget(self, action:"personalcareButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    //        personalProductButton.titleLabel?.adjustsFontSizeToFitWidth = true
    //
    //        var closeButton = UIButton(frame: CGRectMake(posX + w - 21, posY - 21, 42, 42))
    //        closeButton.setImage(UIImage(named: "close.png") as UIImage?, forState: .Normal)
    //        closeButton.addTarget(self, action:"closePopUpView:", forControlEvents: UIControlEvents.AllEvents)
    //        closeButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
    //        closeButton.titleLabel?.adjustsFontSizeToFitWidth = true
    //
    //        popUpView.addSubview(laundaryProductButton)
    //        popUpView.addSubview(personalProductButton)
    //        popUpView.addSubview(houseHoldButton)
    //        popUpView.addSubview(label)
    //        self.view.addSubview(closeButton)
    //        self.view.addSubview(popUpView)
    //
    //    }
    
    //    func houseHoldButtonPressed(sender:UIButton!) {
    //        Singleton.sharedInstance.isHousholdProduct = true
    //        Singleton.sharedInstance.currentProductsDetails = []
    //        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController")
    //        self.showViewController(vc as UIViewController, sender: vc)
    //
    //    }
    
    func loadProductQuestionController(alert: UIAlertAction!) {
//        //Get path of Documents directory
//        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        var documentsDirectory:AnyObject = paths[0]
//        var path = documentsDirectory.stringByAppendingPathComponent("storeDictionary.plist")
//        
//        //Retrieve contents from file at specified path
//        var data = NSMutableDictionary(contentsOfFile: path)
//        Singleton.sharedInstance.answersProductQuestions = data!
        
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ProductQuestionViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    
    func closePopUpView(sender:UIButton!) {
        backgroundOne.alpha = 1
        startBtn.alpha = 1
        textLabel.alpha = 1
        startBtn.enabled = true
        popUpView.removeFromSuperview()
        sender.removeFromSuperview()
    }
    
    // load product detail view controller
    func loadScanController(){
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    // load product detail view controller
    func loadPersonalQuestionController(alert: UIAlertAction!){
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("PersonalQuestionViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    
    @IBAction func onClickInfoButton(sender: UIButton) {
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("InfoViewController")
        
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}