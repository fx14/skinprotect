//
//  FeedbackViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 05/05/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import Social
import Bolts
import FBSDKShareKit


class FeedbackViewController: UIViewController, LineChartDelegate {
    
    var label = UILabel()
    var lineChart: LineChart!
    
    let w = UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 10
    let h = UIScreen.mainScreen().bounds.height / 10
    let graphHeight = UIScreen.mainScreen().bounds.height / 3
    
    // Product XML questions
    var answers = NSMutableDictionary()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    var posY: CGFloat = 0.0
    var posX: CGFloat = 0.0
    
    let SHAMPOO = 1
    let HAIRCONDITIONER = 2
    let BUBBLEBATH = 3
    let SHOWERGEL = 4
    let HANDSOAP = 5
    let BODYLOTION = 6
    let FACECREAM = 7
    let HANDCREAM = 8
    let MALE = "male_usage"
    let FEMALE = "female_usage"
    
    var isShampoo = false
    var isHairConditioner = false
    var isBubbleBath = false
    var isShowerGel = false
    var isHandSoap = false
    var isBodyLotion = false
    var isFaceCream = false
    var isHandCream = false
    var isFeedbackGenerated = false
    
    // All Alert message
    var faceCreamWarningAlertMessage = ""
    var faceCreamOkAlertMessage = ""
    var bodyLotionWarningAlertMessage = ""
    var bodyLotionOkAlertMessage = ""
    var handCreamWarningAlertMessage = ""
    var handCreamOkAlertMessage = ""
    var bubbleBathWarningAlertMessage = ""
    var bubbleBathOkAlertMessage = ""
    var handSoapWarningAlertMessage = ""
    var handSoapOkAlertMessage = ""
    var showerGelWarningAlertMessage = ""
    var showerGelOkAlertMessage = ""
    var shampooWarningAlertMessage = ""
    var shampooOkAlertMessage = ""
    var hariConditionerWarningAlertMessage = ""
    var hariConditionerOkAlertMessage = ""
    
    var userFaceCreamUsage = ""
    var userBodyLotionUsage = ""
    var userHandCreamUsage = ""
    var userBubbleBathUsage = ""
    var userHandSoapUsage = ""
    var userShowerGelUsage = ""
    var userShampooUsage = ""
    var userHairConditionerUsage = ""
    
    // Facebook message
    var facebookMsg = ""
    
    
    
    var leftColorViewYPosition:CGFloat = 0
    
    var (age, gender) = (0,"")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title screen
        self.title = NSLocalizedString("feedback", comment: "Feedback")
        
        // Setup position
        posY = screenSize.height / 100
        posX = (screenSize.width - w) / 2
        
        // Load answers
        answers = Singleton.sharedInstance.answersProductQuestions;
        
        view.addSubview(scrollView)
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height)
        
        (age, gender) = currentUserAge()
        age = age - 1 // array index start from 0, so substract 1
        
        generateGraph()
        
        updateLocalDatabase()
        if isFeedbackGenerated {
            generateShareSocial()
        }
        generateThankYouMessage()
        generateJSON()
        scrollView.contentSize = CGSizeMake(screenSize.width, posY)
    }
    
    
    
    // Generate JSON from NSMutableDictionary of personal and product questions
    private func generateJSON() {
        
        var productQuestionData:NSMutableDictionary = NSMutableDictionary()
        
        // Product question
        for (key, value) in answers {
            if let dicValue = value as? NSDictionary {
                for (key1, value1) in dicValue {
                    let nKey:String = key.description + "-" + key1.description
                    var value1String = value1.description
                    value1String = value1String.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    value1String = value1String.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    productQuestionData.setValue(value1String, forKey:nKey)
                }
            } else {
                let mykey:String = key.description
                var valueString = value.description
                valueString = valueString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                valueString = valueString.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                productQuestionData.setValue(valueString, forKey: mykey)
            }
        }
        
        
        
        // Personal question
        var personalQuestionData:NSMutableDictionary = NSMutableDictionary()
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "PersonalQuestion")
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        
        
        if result?.count > 0 {
            // load the personalized question
            let countElements = result?.count
            let resultItem = result![countElements!-1] as! PersonalQuestion
            personalQuestionData.setValue(resultItem.gender, forKey: "gender")
            gender = resultItem.gender
            personalQuestionData.setValue(resultItem.age, forKey: "age")
            personalQuestionData.setValue(resultItem.height, forKey: "height")
            personalQuestionData.setValue(resultItem.weight, forKey: "weight")
            personalQuestionData.setValue(resultItem.nationality, forKey: "nationality")
            personalQuestionData.setValue(resultItem.zip, forKey: "zip")
            personalQuestionData.setValue(resultItem.education, forKey: "education")
            personalQuestionData.setValue(resultItem.skin_allergy, forKey: "skin_allergy")
            if resultItem.body_part != "" {
                personalQuestionData.setValue(resultItem.body_part, forKey: "allergy_body_part")
            }
            if resultItem.doctor_contact != "" {
                personalQuestionData.setValue(resultItem.doctor_contact, forKey: "doctor_contact")
            }
            personalQuestionData.setValue(resultItem.contact, forKey: "contact")
            if resultItem.email != "" {
              personalQuestionData.setValue(resultItem.email, forKey: "email")
            }
        }
        
        // app found information
        var idData:NSMutableDictionary = NSMutableDictionary()
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0] as! Configuration
                idData.setValue(managedObject.app_identifier, forKey: "user_id")
                idData.setValue(managedObject.app_found_from, forKey: "app_from")
            }
        }
        
        var jsonObjPersonalQuestion = JSON(personalQuestionData)
        var jsonObjProductQuestion = JSON(productQuestionData)
        var jsonObjidQuestion = JSON(idData)
        
        var s = "app_q:" + jsonObjidQuestion.description
        s += ", per_q:" + jsonObjPersonalQuestion.description
        s += ", prod_q:" + jsonObjProductQuestion.description
        s = "product=[" + s + "]"
        
        senddatatest(s, url: "http://129.132.42.250/~students/db_connect/products_result_files/products_result.php")
        
        // update male/female usage result
        sendUserUsageDataToDatabase()
    }
    
    // update usage data
    func sendUserUsageDataToDatabase() {
        var post:String = "gender="
        if gender == NSLocalizedString("male", comment: "Male") {
            post += MALE
        } else {
            post += FEMALE
        }
        post += "&age=" + (age + 1).description
        
        if isShampoo {
            post += "&shampoo=" + userShampooUsage
        }
        if isHairConditioner {
            post += "&hairconditioner=" + userHairConditionerUsage
        }
        if isShowerGel {
            post += "&showergel=" + userShowerGelUsage
        }
        if isHandSoap {
            post += "&handsoap=" + userHandSoapUsage
        }
        if isBubbleBath {
            post += "&bubblebath=" + userBubbleBathUsage
        }
        if isHandCream {
            post += "&handcream=" + userHandCreamUsage
        }
        if isBodyLotion {
            post += "&bodylotion=" + userBodyLotionUsage
        }
        if isFaceCream {
            post += "&facecream=" + userFaceCreamUsage
        }
        
        senddatatest(post, url: "http://129.132.42.250/~students/db_connect/updateUsageDB.php")
    }
    
    func senddatatest(params: String, url: String) {
        var post:NSString = params
        println(post)
        var url:NSURL = NSURL(string: url)!
        
        var postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var postLength:NSString = String( postData.length )
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                var error: NSError?
                
            } else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "INFO"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "INFO"
            alertView.message = "Connection Failure"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
    
    private func permenantlyStoreConfiguration() {
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) //Get Path of Documents Directory
        var documentsDirectory:AnyObject = paths[0]
        var path = documentsDirectory.stringByAppendingPathComponent("storeDictionary.plist")
        var fileManager = NSFileManager.defaultManager()
        var fileExists:Bool = fileManager.fileExistsAtPath(path)
        var data : NSMutableDictionary?
        
        //Check if plist file exists at path specified
        if fileExists == false {
            //File does not exists
            data = NSMutableDictionary () //Create data dictionary for storing in plist
        } else  {
            //File exists – retrieve data from plist inside data dictionary
            data = NSMutableDictionary(contentsOfFile: path)
            Singleton.sharedInstance.answersProductQuestions  = data!
        }
        
        data?.writeToFile(path, atomically: true) //Write data to file permanently
    }
    
    // Generate Share Social Media
    private func generateShareSocial() {
        posY += w/10
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.autoidlabs.ch/survey")
        content.contentTitle = String(format: NSLocalizedString("i_use_fb", comment: "usage result"), facebookMsg)
        content.contentDescription = NSLocalizedString("app_description", comment: "App Description")
        content.imageURL = NSURL(string: "http://129.132.42.250/~students/appImages/logo15.jpg")
        
        let button : FBSDKShareButton = FBSDKShareButton()
        //        button.setBackgroundImage(UIImage(named:"facebook_logo.png"), forState: .Normal)
        button.shareContent = content
        button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - w/2) * 0.5, posY, w/2, h)
        posY += h/2
        scrollView.addSubview(button)
        
    }
    
    
    
    
    // Update local databse to product question done
    private func updateLocalDatabase() {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue("1", forKey: "product_question") // todo change 0 to 1
                managedObjectContext!.save(nil)
            }
        }
    }
    
    // Generate thank you message
    private func generateThankYouMessage() {
        let tit = NSLocalizedString("thank_you_participate", comment: "Thank you for participating")
        posY+=h
        let thankyouLabel = generateLabel(tit, xPosition: posX, yPosition: posY, width: w, height: h)
        thankyouLabel.userInteractionEnabled = true
        thankyouLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "labelTapped:"))
        scrollView.addSubview(thankyouLabel)
        posY += h * 2
    }
    
    func labelTapped(sender: UITapGestureRecognizer) {
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    // Check the answers and set to true which graph to design
    private func graphsToDrow() {
        if let ans:[String] = answers[61-1] as? [String] {
            for value in ans {
                if value == NSLocalizedString("shampoo", comment: "Shampoo") {
                    isShampoo = true
                } else if value == NSLocalizedString("hair_conditioner", comment: "Hair Conditioner") {
                    isHairConditioner = true
                } else if value == NSLocalizedString("bubble_bath", comment: "Bubble Bath") {
                    isBubbleBath = true
                } else if value == NSLocalizedString("shower_gel", comment: "Shower Gel") {
                    isShowerGel = true
                } else if value == NSLocalizedString("hand_soap", comment: "Hand Soap") {
                    isHandSoap = true
                } else if value == NSLocalizedString("body_lotion", comment: "Body Lotion") {
                    isBodyLotion = true
                } else if value == NSLocalizedString("face_cream", comment: "Face Cream") {
                    isFaceCream = true
                } else if value == NSLocalizedString("hand_cream", comment: "Hand Cream") {
                    isHandCream = true
                }
            }
        }
    }
    
    func generateGraph() {
        graphsToDrow()
        
        let tit = NSLocalizedString("feedback_title", comment: "Your Habits have an impact on your Skin")
        scrollView.addSubview(generateLabel(tit, xPosition: posX, yPosition: posY, width: w, height: h))
        
        posY+=h
        
        if isShampoo || isHairConditioner { // Hair product
            isFeedbackGenerated = true
            drawHairProductsGraph()
        }
        if isBubbleBath || isHandSoap || isShowerGel {
            isFeedbackGenerated = true
            drawBodyWashGraph()
        }
        if isFaceCream || isBodyLotion || isHandCream {
            isFeedbackGenerated = true
            drawCreamUsageGraph()
        }
        
        // site colored label color
        var view = UIView()
        view.frame = CGRectMake(0, leftColorViewYPosition, posX/2, posY * 2)
        view.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        scrollView.addSubview(view)
        
    }
    
    // Draw the cream usage graph
    private func drawCreamUsageGraph() {
        var resultFaceCreamMale:[CGFloat] = []
        var resultFaceCreamFemale:[CGFloat] = []
        var resultBodyLotionMale:[CGFloat] = []
        var resultBodyLotionFemale:[CGFloat] = []
        var resultHandCreamMale:[CGFloat] = []
        var resultHandCreamFemale:[CGFloat] = []
        var graphValuesMale:[CGFloat] = []
        var graphValuesFemale:[CGFloat] = []
        var agratedValueMale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        var agratedValueFemale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        
        var leChart = LineChart()
        var warningAlert = false
        var okAlert = false
        
        
        var countElements = 0
        
        var myDot:MyDot = MyDot()
        myDot.label = NSLocalizedString("you", comment: "you")
        myDot.age = calculateAgeRange(age)
        myDot.average = 0
        
        if Reachability.isConnectedToNetwork() {
            if isFaceCream {
                resultFaceCreamMale = connectSynchrnousProductDatabase(FACECREAM, gender: MALE)
                resultFaceCreamFemale = connectSynchrnousProductDatabase(FACECREAM, gender: FEMALE)
                graphValuesMale = resultFaceCreamMale
                graphValuesFemale = resultFaceCreamFemale
                countElements = resultFaceCreamMale.count
                
                let avg = calculateFaceCreamUserUsage()
                userFaceCreamUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultFaceCreamMale[age]
                } else {
                    globalAverage = resultFaceCreamFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    faceCreamWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("face_cream", comment: "Face Cream"), globalAverage.description)
                } else {
                    okAlert = true
                    faceCreamOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("face_cream", comment: "Face Cream"), globalAverage.description)
                }
                
            }
            if isBodyLotion {
                resultBodyLotionMale = connectSynchrnousProductDatabase(BODYLOTION, gender: MALE)
                resultBodyLotionFemale = connectSynchrnousProductDatabase(BODYLOTION, gender: FEMALE)
                graphValuesMale = resultBodyLotionMale
                graphValuesFemale = resultBodyLotionFemale
                countElements = resultBodyLotionMale.count
                
                let avg = calculateBodyLotionUserUsage()
                userBodyLotionUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultBodyLotionMale[age]
                } else {
                    globalAverage = resultBodyLotionFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    bodyLotionWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("body_lotion", comment: "Body Lotion"), globalAverage.description)
                } else {
                    okAlert = true
                    bodyLotionOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("body_lotion", comment: "Body Lotion"), globalAverage.description)
                }
                
            }
            if isHandCream {
                resultHandCreamMale = connectSynchrnousProductDatabase(HANDCREAM, gender: MALE)
                resultHandCreamFemale = connectSynchrnousProductDatabase(HANDCREAM, gender: FEMALE)
                graphValuesMale = resultHandCreamMale
                graphValuesFemale = resultHandCreamFemale
                countElements = resultHandCreamMale.count
                
                let avg = calculatehandCreamUserUsage()
                userHandCreamUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultHandCreamMale[age]
                } else {
                    globalAverage = resultHandCreamFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    handCreamWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("hand_cream", comment: "Hand Cream"), globalAverage.description)
                } else {
                    okAlert = true
                    handCreamOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("hand_cream", comment: "Hand Cream"), globalAverage.description)
                }
            }
        } else {
            loadInternetConnectionAlertPopup()
        }
        
        // sum all products value to one array
        if isFaceCream && isBodyLotion && isHandCream {
            for var i = 0; i < resultFaceCreamMale.count; i++ {
                graphValuesMale[i] = resultFaceCreamMale[i] + resultBodyLotionMale[i] + resultHandCreamMale[i]
                graphValuesFemale[i] = resultFaceCreamFemale[i] + resultBodyLotionFemale[i] + resultHandCreamFemale[i]
            }
        } else if isFaceCream && isBodyLotion {
            for var i = 0; i < resultFaceCreamMale.count; i++ {
                graphValuesMale[i] = resultFaceCreamMale[i] + resultBodyLotionMale[i]
                graphValuesFemale[i] = resultFaceCreamFemale[i] + resultBodyLotionFemale[i]
            }
        } else if isFaceCream && isHandCream {
            for var i = 0; i < resultFaceCreamMale.count; i++ {
                graphValuesMale[i] = resultFaceCreamMale[i] + resultHandCreamMale[i]
                graphValuesFemale[i] = resultFaceCreamFemale[i] + resultHandCreamFemale[i]
            }
        } else if isBodyLotion && isHandCream {
            for var i = 0; i < resultBodyLotionMale.count; i++ {
                graphValuesMale[i] =  resultBodyLotionMale[i] + resultHandCreamMale[i]
                graphValuesFemale[i] =  resultBodyLotionFemale[i] + resultHandCreamFemale[i]
            }
        }
        
        agratedValueMale = aggragateValueByCategory(graphValuesMale, count: countElements)
        agratedValueFemale = aggragateValueByCategory(graphValuesFemale, count: countElements)
        
        var labl = UILabel()
        posY += 10
        
        // Side red color bar
        var view1 = UIView()
        view1.frame = CGRectMake(0, posY, posX, h)
        view1.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        scrollView.addSubview(view1)
        
        labl.frame = CGRectMake(posX, posY, w, h)
        posY+=h
        
        if facebookMsg != "" {
            facebookMsg += ", " + myDot.average.description + " kg " + NSLocalizedString("body_creams", comment: "Body Cream")
        } else {
            facebookMsg += myDot.average.description + " kg " + NSLocalizedString("body_creams", comment: "Body Cream")

        }
        
        let text = String(format: NSLocalizedString("you_use_cream", comment: "Cream Usage"), myDot.average.description)
        labl.text = text
        labl.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        //        label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        labl.lineBreakMode = NSLineBreakMode.ByWordWrapping
        labl.numberOfLines = 2
        labl.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(labl)
        
        // simple line with custom x axis labels
        var xLabels: [String] = ["0-10","11-20","21-30","31-40","41-50","51-60","61-70","71<"]
        
        // Add my dot
        myDot.dotColor = Singleton.sharedInstance.colors[3]
        leChart.addDot(myDot)
        
        // Chart properties
        leChart.frame = CGRectMake(posX, posY, w, graphHeight)
        leChart.animation.enabled = true
        leChart.area = true
        posY += graphHeight
        leChart.x.labels.values = xLabels
        leChart.x.labels.visible = true
        leChart.y.labels.visible = true
        leChart.x.grid.visible = true
        leChart.y.grid.visible = false
        leChart.dots.visible = false
        leChart.setTranslatesAutoresizingMaskIntoConstraints(false)
        leChart.delegate = self
        
        // Add aggregate value to graph
        leChart.addLine(agratedValueMale)
        leChart.addLine(agratedValueFemale)
        self.scrollView.addSubview(leChart)
        
        // warning view
        if warningAlert {
            var txt = ""
            var tempH = h
            if faceCreamWarningAlertMessage != "" {
                txt += faceCreamWarningAlertMessage + " \r\n"
            }
            if bodyLotionWarningAlertMessage != "" {
                txt += bodyLotionWarningAlertMessage + " \r\n"
            }
            if handCreamWarningAlertMessage != "" {
                txt += handCreamWarningAlertMessage + " \r\n"
            }
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h+h/2, type: "warning")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY +=  h+h/2 + 30 // TODO: fix this 30
        }
        if okAlert {
            var txt = ""
            if faceCreamOkAlertMessage != "" {
                txt += faceCreamOkAlertMessage + " \r\n"
            }
            if bodyLotionOkAlertMessage != "" {
                txt += bodyLotionOkAlertMessage + " \r\n"
            }
            if handCreamOkAlertMessage != "" {
                txt += handCreamOkAlertMessage + " \r\n"
            }
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h+h/2, type: "ok")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY +=  h+h/2 +  30 // TODO: fix this 30
        }
        
    }
    
    // Draw body wash usage graph
    private func drawBodyWashGraph() {
        var resultBubbleBathMale:[CGFloat] = []
        var resultBubbleBathFemale:[CGFloat] = []
        var resultHandSoapMale:[CGFloat] = []
        var resultHandSoapFemale:[CGFloat] = []
        var resultShowerGelMale:[CGFloat] = []
        var resultShowerGelFemale:[CGFloat] = []
        var graphValuesMale:[CGFloat] = []
        var graphValuesFemale:[CGFloat] = []
        var agratedValueMale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        var agratedValueFemale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        
        var leChart = LineChart()
        var warningAlert = false
        var okAlert = false
        
        
        var countElements = 0
        
        var myDot:MyDot = MyDot()
        myDot.label = NSLocalizedString("you", comment: "you")
        myDot.age = calculateAgeRange(age)
        myDot.average = 0
        
        if Reachability.isConnectedToNetwork() {
            if isBubbleBath {
                resultBubbleBathMale = connectSynchrnousProductDatabase(BUBBLEBATH, gender: MALE)
                resultBubbleBathFemale = connectSynchrnousProductDatabase(BUBBLEBATH, gender: FEMALE)
                graphValuesMale = resultBubbleBathMale
                graphValuesFemale = resultBubbleBathFemale
                countElements = resultBubbleBathMale.count
                
                let avg = calculateBubbleBathUserUsage()
                userBubbleBathUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultBubbleBathMale[age]
                } else {
                    globalAverage = resultBubbleBathFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    bubbleBathWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("bubble_bath", comment: "Bubble Bath"), globalAverage.description)
                } else {
                    okAlert = true
                    bubbleBathOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("bubble_bath", comment: "Bubble Bath"), globalAverage.description)
                }
            }
            if isHandSoap {
                resultHandSoapMale = connectSynchrnousProductDatabase(HANDSOAP, gender: MALE)
                resultHandSoapFemale = connectSynchrnousProductDatabase(HANDSOAP, gender: FEMALE)
                graphValuesMale = resultHandSoapMale
                graphValuesFemale = resultHandSoapFemale
                countElements = resultHandSoapMale.count
                
                let avg = calculateHandSoapUserUsage()
                userHandSoapUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultHandSoapMale[age]
                } else {
                    globalAverage = resultHandSoapFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    handSoapWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("hand_soap", comment: "Hand Soap"), globalAverage.description)
                } else {
                    okAlert = true
                    handSoapOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("hand_soap", comment: "Hand Soap"), globalAverage.description)
                }
                
            }
            if isShowerGel {
                resultShowerGelMale = connectSynchrnousProductDatabase(SHOWERGEL, gender: MALE)
                resultShowerGelFemale = connectSynchrnousProductDatabase(SHOWERGEL, gender: FEMALE)
                graphValuesMale = resultShowerGelMale
                graphValuesFemale = resultShowerGelFemale
                countElements = resultShowerGelMale.count
                
                let avg = calculateShowerGelUserUsage()
                userShowerGelUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultShowerGelMale[age]
                } else {
                    globalAverage = resultShowerGelFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    showerGelWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("shower_gel", comment: "Shower Gel"), globalAverage.description)
                } else {
                    okAlert = true
                    showerGelOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("shower_gel", comment: "Shower Gel"), globalAverage.description)
                }
                
            }
        } else {
            loadInternetConnectionAlertPopup()
        }
        
        // sum all products value to one array
        if isBubbleBath && isShowerGel && isHandSoap {
            for var i = 0; i < resultBubbleBathMale.count; i++ {
                graphValuesMale[i] = resultBubbleBathMale[i] + resultShowerGelMale[i] + resultHandSoapMale[i]
                graphValuesFemale[i] = resultBubbleBathFemale[i] + resultShowerGelFemale[i] + resultHandSoapFemale[i]
            }
        } else if isBubbleBath && isShowerGel {
            for var i = 0; i < resultBubbleBathMale.count; i++ {
                graphValuesMale[i] = resultBubbleBathMale[i] + resultShowerGelMale[i]
                graphValuesFemale[i] = resultBubbleBathFemale[i] + resultShowerGelFemale[i]
            }
        } else if isBubbleBath && isHandSoap {
            for var i = 0; i < resultBubbleBathMale.count; i++ {
                graphValuesMale[i] = resultBubbleBathMale[i] + resultHandSoapMale[i]
                graphValuesFemale[i] = resultBubbleBathFemale[i] + resultHandSoapFemale[i]
            }
        } else if isShowerGel && isHandSoap {
            for var i = 0; i < resultBubbleBathMale.count; i++ {
                graphValuesMale[i] =  resultShowerGelMale[i] + resultHandSoapMale[i]
                graphValuesFemale[i] =  resultShowerGelFemale[i] + resultHandSoapFemale[i]
            }
        }
        
        agratedValueMale = aggragateValueByCategory(graphValuesMale, count: countElements)
        agratedValueFemale = aggragateValueByCategory(graphValuesFemale, count: countElements)
        
        var labl = UILabel()
        posY += 10
        
        // Side red color bar
        var view1 = UIView()
        view1.frame = CGRectMake(0, posY, posX, h)
        view1.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        scrollView.addSubview(view1)
        
        labl.frame = CGRectMake(posX, posY, w, h)
        posY+=h
        
        if facebookMsg != "" {
            facebookMsg += " and " + myDot.average.description + " kg " + NSLocalizedString("body_products", comment: "Body Products")

        } else {
            facebookMsg += myDot.average.description + " kg " + NSLocalizedString("body_products", comment: "Body Products")
        }
        
        let text = String(format: NSLocalizedString("you_use_body_wash", comment: "Body Wash Products"), myDot.average.description)
        labl.text = text
        labl.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        //        label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        labl.lineBreakMode = NSLineBreakMode.ByWordWrapping
        labl.numberOfLines = 2
        labl.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(labl)
        
        // simple line with custom x axis labels
        var xLabels: [String] = ["0-10","11-20","21-30","31-40","41-50","51-60","61-70","71<"]
        
        // Add my dot
        myDot.dotColor = Singleton.sharedInstance.colors[3]
        leChart.addDot(myDot)
        
        // Chart properties
        leChart.frame = CGRectMake(posX, posY, w, graphHeight)
        leChart.animation.enabled = true
        leChart.area = true
        posY += graphHeight
        leChart.x.labels.values = xLabels
        leChart.x.labels.visible = true
        leChart.y.labels.visible = true
        leChart.x.grid.visible = true
        leChart.y.grid.visible = false
        leChart.dots.visible = false
        leChart.setTranslatesAutoresizingMaskIntoConstraints(false)
        leChart.delegate = self
        
        // Add aggregate value to graph
        leChart.addLine(agratedValueMale)
        leChart.addLine(agratedValueFemale)
        self.scrollView.addSubview(leChart)
        
        // warning view
        if warningAlert {
            var txt = ""
            var tempH = h
            if bubbleBathOkAlertMessage != "" {
                txt += bubbleBathWarningAlertMessage + " \r\n"
            }
            if showerGelWarningAlertMessage != "" {
                txt += showerGelWarningAlertMessage + " \r\n"
            }
            if handSoapWarningAlertMessage != "" {
                txt += handSoapWarningAlertMessage + " \r\n"
            }
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h+h/2, type: "warning")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY +=  h+h/2 + 30 // TODO: fix this 30
        }
        if okAlert {
            var txt = ""
            if bubbleBathOkAlertMessage != "" {
                txt += bubbleBathOkAlertMessage + " \r\n"
            }
            if showerGelOkAlertMessage != "" {
                txt += showerGelOkAlertMessage + " \r\n"
            }
            if handSoapOkAlertMessage != "" {
                txt += handSoapOkAlertMessage + " \r\n"
            }
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h+h/2, type: "ok")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY +=  h+h/2 +  30 // TODO: fix this 30
        }
        
    }
    
    // Draw hair product usage graph
    private func drawHairProductsGraph() {
        var resultShampooMale:[CGFloat] = []
        var resultShampooFemale:[CGFloat] = []
        var resultHairConditionerMale:[CGFloat] = []
        var resultHairConditionerFemale:[CGFloat] = []
        var graphValuesMale:[CGFloat] = []
        var graphValuesFemale:[CGFloat] = []
        var agratedValueMale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        var agratedValueFemale:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        
        var leChart = LineChart()
        var warningAlert = false
        var okAlert = false
        
        var countElements = 0
        
        
        var myDot:MyDot = MyDot()
        myDot.label = NSLocalizedString("you", comment: "you")
        myDot.age = calculateAgeRange(age)
        myDot.average = 0
        
        if Reachability.isConnectedToNetwork() {
            if isShampoo {
                resultShampooMale = connectSynchrnousProductDatabase(SHAMPOO, gender: MALE)
                resultShampooFemale = connectSynchrnousProductDatabase(SHAMPOO, gender: FEMALE)
                graphValuesMale = resultShampooMale
                graphValuesFemale = resultShampooFemale
                countElements = resultShampooMale.count
                
                let avg = calculateShampooUserUsage()
                userShampooUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultShampooMale[age]
                } else {
                    globalAverage = resultShampooFemale[age]
                }
                
                if avg > globalAverage {
                    warningAlert = true
                    shampooWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("shampoo", comment: "Shampoo"), globalAverage.description)
                } else {
                    okAlert = true
                    shampooOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description, NSLocalizedString("shampoo", comment: "Shampoo"), globalAverage.description)
                    
                    // Add value to graph
                    //                leChart.addLine(resultShampoo)
                }
            }
            if isHairConditioner {
                resultHairConditionerMale = connectSynchrnousProductDatabase(HAIRCONDITIONER, gender: MALE)
                resultHairConditionerFemale = connectSynchrnousProductDatabase(HAIRCONDITIONER, gender: FEMALE)
                graphValuesMale = resultHairConditionerMale
                graphValuesFemale = resultHairConditionerFemale
                countElements = resultHairConditionerMale.count
                
                let avg:CGFloat = calculateHairConditionerUserUsage()
                userHairConditionerUsage = avg.description
                myDot.average += avg
                
                var globalAverage: CGFloat = 0
                if gender == NSLocalizedString("male", comment: "Male") {
                    globalAverage = resultHairConditionerMale[age]
                } else {
                    globalAverage = resultHairConditionerFemale[age]
                }
                
                if avg > globalAverage { // age starts from 0
                    warningAlert = true
                    hariConditionerWarningAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("hair_conditioner", comment: "Hair Conditioner"), globalAverage.description)
                    
                } else {
                    okAlert = true
                    hariConditionerOkAlertMessage = String(format: NSLocalizedString("you_use", comment: "usage result"), avg.description , NSLocalizedString("hair_conditioner", comment: "Hair Conditioner"), globalAverage.description)
                }
            }
            
        } else {
            loadInternetConnectionAlertPopup()
        }
        
        
        if isShampoo && isHairConditioner {
            for var i = 0; i < countElements; i++ {
                graphValuesMale[i] = resultShampooMale[i] + resultHairConditionerMale[i]
                graphValuesFemale[i] = resultShampooFemale[i] + resultHairConditionerFemale[i]
            }
        }
        
        agratedValueMale = aggragateValueByCategory(graphValuesMale, count: countElements)
        agratedValueFemale = aggragateValueByCategory(graphValuesFemale, count: countElements)
        
        var labl = UILabel()
        posY += 10
        
        // Side red color bar
        var view1 = UIView()
        view1.frame = CGRectMake(0, posY, posX, h)
        view1.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        scrollView.addSubview(view1)
        
        labl.frame = CGRectMake(posX, posY, w, h)
        posY+=h
        
        if facebookMsg != "" {
            facebookMsg += myDot.average.description + " kg " + NSLocalizedString("hair_products", comment: "Hair Products")
        }
        
        let text = String(format: NSLocalizedString("you_use_hair_product", comment: "Hair Products"), myDot.average.description)
        labl.text = text
        labl.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f).colorWithAlphaComponent(0.4)
        //        label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        labl.lineBreakMode = NSLineBreakMode.ByWordWrapping
        labl.numberOfLines = 2
        labl.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(labl)
        
        // simple line with custom x axis labels
        var xLabels: [String] = ["0-10","11-20","21-30","31-40","41-50","51-60","61-70","71<"]
        
        // Add my dot
        myDot.dotColor = Singleton.sharedInstance.colors[3]
        leChart.addDot(myDot)
        
        // Chart properties
        leChart.frame = CGRectMake(posX, posY, w, graphHeight)
        leChart.animation.enabled = true
        leChart.area = true
        posY += graphHeight
        leChart.x.labels.values = xLabels
        leChart.x.labels.visible = true
        leChart.y.labels.visible = true
        leChart.x.grid.visible = true
        leChart.y.grid.visible = false
        leChart.dots.visible = false
        leChart.setTranslatesAutoresizingMaskIntoConstraints(false)
        leChart.delegate = self
        
        // Add aggregate value to graph
        leChart.addLine(agratedValueMale)
        leChart.addLine(agratedValueFemale)
        self.scrollView.addSubview(leChart)
        
        // warning view
        if warningAlert {
            let txt = shampooWarningAlertMessage + " \r\n" + hariConditionerWarningAlertMessage
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h, type: "warning")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY += h + 30 // TODO: fix this 30
        }
        if okAlert {
            let txt = shampooOkAlertMessage + " \r\n" + hariConditionerOkAlertMessage
            var (label, image) = alertView(txt, xPosition: posX, yPosition: posY, width: w, height: h, type: "ok")
            self.scrollView.addSubview(label)
            self.scrollView.addSubview(image)
            posY += h +  30 // TODO: fix this 30
        }
    }
    
    // Calculate the range of the current user
    private func calculateAgeRange(age: Int) -> CGFloat {
        if age <= 10 {
            return 1
        } else if age >= 11 && age <= 20 {
            return 2
        } else if age >= 21 && age <= 30 {
            return 3
        } else if age >= 31 && age <= 40 {
            return 4
        } else if age >= 41 && age <= 50 {
            return 5
        } else if age >= 51 && age <= 60 {
            return 6
        } else if age >= 61 && age <= 70 {
            return 7
        } else if age >= 41 {
            return 8
        }
        return 0
    }
    
    // Aggrate the values by age category
    private func aggragateValueByCategory (arrayValue: [CGFloat], count: Int) -> [CGFloat] {
        var agratedValue:[CGFloat] = [0,0,0,0,0,0,0,0,0,0]
        // Agregate the values to [0-10][11-20][21-30][31-40][41-50][51-60][61-70][71-]
        for var i = 0; i < count; i++ {
            if i <= 10 {
                agratedValue[1] += arrayValue[i]
            } else if i >= 11 && i <= 20 {
                agratedValue[2] += arrayValue[i]
            } else if i >= 21 && i <= 30 {
                agratedValue[3] += arrayValue[i]
            } else if i >= 31 && i <= 40 {
                agratedValue[4] += arrayValue[i]
            } else if i >= 41 && i <= 50 {
                agratedValue[5] += arrayValue[i]
            } else if i >= 51 && i <= 60 {
                agratedValue[6] += arrayValue[i]
            } else if i >= 61 && i <= 70 {
                agratedValue[7] += arrayValue[i]
            } else if i >= 41 {
                agratedValue[8] += arrayValue[i]
                agratedValue[9] += arrayValue[i]
            }
        }
        // divide by number of aggragated users
        for var i = 0; i < agratedValue.count; i++ {
            agratedValue[i] = agratedValue[i] / 10
        }
        return agratedValue
    }
    
    // Alert view
    private func alertView(title: String, xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat, type:String) -> (UILabel, UIImageView) {
        var posY = yPosition
        var imageView: UIImageView = UIImageView()
        imageView.frame = CGRectMake(xPosition, posY, 30, 30)
        
        posY += 30
        
        var qLabel: UILabel = UILabel()
        qLabel.frame = CGRectMake(xPosition, posY, width, height) // TODO: fix the size
        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        qLabel.numberOfLines = 5
        if type == "warning" {
            qLabel.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
            imageView.image = UIImage(named:"dialog_warning.png")
        } else if type == "ok" {
            qLabel.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
            imageView.image = UIImage(named:"dialog_information.png")
        }
        
        qLabel.adjustsFontSizeToFitWidth = true
        qLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 10.0)
        qLabel.textAlignment = NSTextAlignment.Center
        qLabel.text = title
        qLabel.textColor = UIColor.blackColor()
        
        return (qLabel, imageView)
        
    }
    
    // Body Wash product image quantity
    private func claculateImageQuantityForBodyWash(questionID: Int) -> CGFloat {
        // Image selected value
        if let imageQuantity:Int = answers[questionID] as? Int {
            switch imageQuantity {
            case 1:
                return 2.4  // 2 grams
            case 2:
                return 4.2 // 5 grams
            case 3:
                return 6 // grams
            case 4:
                return 8.5 // 8 grams
            default:
                return 4.25 // default
            }
        }
        return 1
    }
    
    // Cream product image quantity
    private func claculateImageQuantityForCreams(questionID: Int) -> CGFloat {
        // Image selected value
        if let imageQuantity:Int = answers[questionID] as? Int {
            switch imageQuantity {
            case 1:
                return 0.2  // 2 grams
            case 2:
                return 0.4 // 5 grams
            case 3:
                return 0.7 // grams
            case 4:
                return 1.0// 8 grams
            default:
                return 0.55 // default
            }
        }
        return 1
    }
    
    // Hair Wash product image quantity
    private func claculateImageQuantityForHairWash(questionID: Int) -> CGFloat {
        // Image selected value
        if let imageQuantity:Int = answers[questionID] as? Int {
            switch imageQuantity {
            case 1:
                return 2.7  // 2 grams
            case 2:
                return 5.3 // 5 grams
            case 3:
                return 7.8 // grams
            case 4:
                return 11 // 8 grams
            default:
                return 5.5 // default
            }
        }
        return 1
    }
    
    // Face Cream usage of the user
    private func calculateFaceCreamUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[116-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[117-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[118-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[119-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[120-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForCreams(124-1)
        
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Liquind Hand Soap usage of the user
    private func calculateHandSoapUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[107-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[108-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[109-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[110-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[111-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForBodyWash(115-1)
        
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Hand Cream usage of the user
    private func calculatehandCreamUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[146-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[147-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[148-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[149-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[150-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForCreams(154-1)
        
        // Times per use
        if let timesPerUse:String = answers[155-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Body Lotion usage of the user
    private func calculateBodyLotionUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[135-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[136-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[137-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[138-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[139-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForCreams(143-1)
        
        // Times per use
        if let timesPerUse:String = answers[144-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Bubble Hand Soap usage of the user
    private func calculateShowerGelUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[85-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[86-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[87-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[88-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[89-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForBodyWash(93-1)
        
        // Times per use
        if let timesPerUse:String = answers[94-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Bubble bath usage of the user
    private func calculateBubbleBathUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[96-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[97-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[98-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[99-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[100-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForBodyWash(104-1)
        
        // Times per use
        if let timesPerUse:String = answers[105-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        println(times)
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    // Shampoo usage of the user
    private func calculateShampooUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[63-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[64-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[65-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[66-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[67-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForHairWash(71-1)
        
        // Times per use
        if let timesPerUse:String = answers[72-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        println(times)
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    private func calculateHairConditionerUserUsage() -> CGFloat {
        var times: CGFloat = 0
        // Times per day, week, month or year
        if let ans:String = answers[74-1] as? String { // ID SHOULD BE EXACTLY SAME TO THE XML
            switch ans {
            case NSLocalizedString("every_day", comment: "Every Day"):
                let temp:String = answers[75-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 365 // per year
            case NSLocalizedString("every_week", comment: "Every week"):
                let temp:String = answers[76-1] as! String
                times = CGFloat(temp.toInt()!)
                times *= 52
            case NSLocalizedString("sometimes_month", comment: "Monthly"):
                let temp:String = answers[77-1] as! String
                times = CGFloat(temp.toInt()!)
            case NSLocalizedString("sometimes_year", comment: "Yearly"):
                let temp:String = answers[78-1] as! String
                times = CGFloat(temp.toInt()!)
            default:
                times = 1
            }
        }
        
        times *= claculateImageQuantityForHairWash(82-1)
        
        // Times per use
        if let timesPerUse:String = answers[83-1] as? String {
            times *= CGFloat(timesPerUse.toInt()!)
        }
        println(times)
        let result = CGFloat(times) / 1000.0
        return result
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    * Line chart delegate method.
    */
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "Age: \(x)     Average: \(yValues)"
    }
    
    /**
    * Redraw chart on device rotation.
    */
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = lineChart {
            chart.setNeedsDisplay()
        }
    }
    
    // Popup message for missing connection
    private func loadInternetConnectionAlertPopup() {
        let m = NSLocalizedString("connect_to_internet", comment: "Please connect to the internet")
        var alert = UIAlertController(title: "", message: m, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: self.checkInternetConnection))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // load product detail view controller
    func checkInternetConnection(alert: UIAlertAction!) {
        if Reachability.isConnectedToNetwork() {
            generateGraph()
        } else {
            
        }
    }
    
    // Calculate the current user age
    private func currentUserAge() -> (Int, String) {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "PersonalQuestion")
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        
        var age:Int = 1
        var gender = ""
        if result?.count > 0 {
            // load the personalized question
            let countElements = result?.count
            let resultItem = result![countElements!-1] as! PersonalQuestion
            age = resultItem.age.toInt()!
            gender = resultItem.gender
        }
        
        return (age, gender)
    }
    
    private func generateLabel(title: String, xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UILabel {
        var qLabel: UILabel = UILabel()
        qLabel.frame = CGRectMake(xPosition, yPosition, width, height)
        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        qLabel.numberOfLines = 2
        qLabel.backgroundColor = UIColor.orangeColor()
        qLabel.adjustsFontSizeToFitWidth = true
        qLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        qLabel.textAlignment = NSTextAlignment.Center
        qLabel.text = title
        qLabel.textColor = UIColor.whiteColor()
        return qLabel
    }
    
    func connectSynchrnousProductDatabase(category: Int, gender:String) -> [CGFloat] {
        var result:[CGFloat] = []
        
        let urlPath: String = "http://129.132.42.250/~students/db_connect/request_feedback.php?catID=" + category.description + "&gender=" + gender
        var url: NSURL = NSURL(string: urlPath)!
        var request1: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var error: NSErrorPointer = nil
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
        var err: NSError
        
        if let jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
            
            var nrUsersField = ""
            var quantityField = ""
            
            switch category {
            case 1: // Shampoo
                nrUsersField = "s_nr_users"
                quantityField = "s_quantity"
            case 2: // Hair Conditioner
                nrUsersField = "hair_c_nr_users"
                quantityField = "hair_c_quantity"
            case 3: // Bubble Bath
                nrUsersField = "b_b_nr_users"
                quantityField = "b_b_quantity"
            case 4: // Shower Gel
                nrUsersField = "s_g_nr_users"
                quantityField = "s_g_quantity"
            case 5: // Hand Soap
                nrUsersField = "h_s_nr_users"
                quantityField = "h_s_quantity"
            case 6: // Body Lotion
                nrUsersField = "b_l_nr_users"
                quantityField = "b_l_quantity"
            case 7: // Face Cream
                nrUsersField = "f_c_nr_users"
                quantityField = "f_c_quantity"
            case 8: // Hand Cream
                nrUsersField = "hand_c_nr_users"
                quantityField = "hand_c_quantity"
            default:
                nrUsersField = ""
                quantityField = ""
            }
            
            for value in jsonResult {
                var nrUsers:CGFloat = 1.0
                
                // TODO different request for different category
                if let s_nr_users = value[nrUsersField] as? String {
                    if let n = NSNumberFormatter().numberFromString(s_nr_users) {
                        nrUsers = CGFloat(n)
                    }
                }
                var quantity:CGFloat = 0.0
                if let s_quantity = value[quantityField] as? String {
                    if let n = NSNumberFormatter().numberFromString(s_quantity) {
                        quantity = CGFloat(n)
                    }
                }
                var temp = quantity / nrUsers
                result.append(temp)
            }
        }
        return result
    }
}