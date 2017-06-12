//
//  ProductQuestionViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 25/03/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import CoreData

class ProductQuestionViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Contains all questions parsed from XML
    private var questions = NSMutableArray()
    private var choices:[String] = []
    
    private var sliderResultLabel = UILabel()
    private var nextButton = UIButton()
    private var backButton = UIButton()
    
    private var tickImage = UIImageView()
    private var questionImages:[UIImageView] = []
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    let w = UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 10
    let h = UIScreen.mainScreen().bounds.height / 7
    
    enum PickerComponent:Int {
        case size = 0
        case topping = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height + 300)
        
        let image = UIImage(named:"home.png") as UIImage!
        var btnBack:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btnBack.addTarget(self, action: "homeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(image, forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        //        let backButton = UIBarButtonItem(title: "< back", style: UIBarButtonItemStyle.Done, target: self, action: nil)
        //
        //        backButton.setBackButtonBackgroundImage(UIImage(named: "flash.png"), forState: UIControlState.Normal, barMetrics: UIBarMetrics(rawValue: 0)!)
        //        navigationItem.backBarButtonItem = backButton
        
        
        //        let backButton = UIBarButtonItem(title: "<", style: UIBarButtonItemStyle.Done, target: self, action: "loadMainController:")
        //        let backImg: UIImage = UIImage(named: "flash")!
        //        backButton.setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        
        //        navigationItem.leftBarButtonItem = backButton
        
        // set title screen
        self.title = NSLocalizedString("product_questions", comment: "Product Questions")
        
        let xmlAnalyzer = XMLPersonalQuestionsAnalyzer()
        
        questions = xmlAnalyzer.beginParsingXML("product")
        
        // set the questions to Singleton class
        Singleton.sharedInstance.productQiestion = questions
        
        generateLayout()
    }
    
    @IBAction func homeButtonPressed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    // load product detail view controller
    func loadMainController(alert: UIAlertAction!){
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    // Generate layout based on the question
    private func generateLayout() {
        // load the dictionary from the array
        let count = Singleton.sharedInstance.currentProductQNr
        //        println(count)
        let question = questions[count] as! NSMutableDictionary
        var isNextQuestion = true
        //        println(question["questiondesc"] as? String)
        
        // Load the parent question id
        if let parentQuestionID = question["parentquestionID"] as? [String] {
            // Load the parent question result
            if let parentQuestionValue = question["valuecondition"] as? [String] {
                // Load all parent questions
                for var i = 0; i < parentQuestionID.count; i++ {
                    // Load the answer
                    let answers = Singleton.sharedInstance.answersProductQuestions
                    if let ans: String = answers[parentQuestionID[i].toInt()!-1] as? String {
                        let conditionAns:String = parentQuestionValue[i] as String
                        if ans == conditionAns {
                            isNextQuestion = true
                            break
                        } else {
                            isNextQuestion = false
                        }
                    } else {
                        isNextQuestion = false
                    }
                    var exitLoop = false
                    //In case of checkbox, we have more answers
                    if let ans: [String] = answers[parentQuestionID[i].toInt()!-1] as? [String] {
                        let conditionAns:String = parentQuestionValue[i] as String
                        for var j = 0; j < ans.count; j++ {
                            if ans[j] == conditionAns {
                                isNextQuestion = true
                                exitLoop = true
                                break
                            } else {
                                isNextQuestion = false
                            }
                        }
                    }
                    if exitLoop {
                        break
                    }
                }
            }
        }
        
        if isNextQuestion {
            // add to the done question array the current question
            Singleton.sharedInstance.doneProductQuestions.insert(Singleton.sharedInstance.currentProductQNr, atIndex: Singleton.sharedInstance.doneProductQuestionPosition)
            var t =  Singleton.sharedInstance.doneProductQuestions
            Singleton.sharedInstance.doneProductQuestionPosition++
            var x = Singleton.sharedInstance.doneProductQuestionPosition
            
            // load the type id of the question
            if let value = question["typeid"] as? String {
                if value == "1" { // radio button
                    self.loadRadioButtonQuestion(question as NSDictionary)
                } else if value == "2" {
                    self.loadCheckBoxQuestion(question as NSDictionary)
                } else if value == "3" {
                    self.loadSliderQuestion(question as NSDictionary)
                } else if value == "4" {
                    self.loadDropDownQuestion(question as NSDictionary)
                } else if value == "6" {
                    self.loadInputTextQuestion(question as NSDictionary)
                } else if value == "7" {
                    self.loadEmailInputQuestion(question as NSDictionary)
                } else if value == "9" {
                    self.loadInputNumberQuestion(question as NSDictionary)
                } else if value == "10" {
                    self.loadBarcodeScannerView(question as NSDictionary)
                } else if value == "11" {
                    self.loadGotoQuestion(question as NSDictionary)
                } else if value == "12" {
                    self.loadImageSelectionQuestion(question as NSDictionary)
                }
            }
        } else {
            nextQuestionCondition()
        }
        
    }
    
    // Radio button question generator (1)
    private func loadRadioButtonQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        // radio buttons
        var possibleChoices = q["choices"] as! [String]
        var radioButtons:[MyRadioButton] = []
        
        
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        // create radiobuttons from number of answers
        for var i = 0; i < possibleChoices.count; i++ {
            distance += 10
            var radioButton = MyRadioButton(frame: CGRectMake(posX, distance, w/1.5 , screenSize.height/14))
            radioButtons.append(radioButton)
            //            println(possibleChoices[i])
            radioButton.setTitle(possibleChoices[i], forState: UIControlState.Normal)
            radioButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingHead
            radioButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            radioButton.setTitleColor(UtilityClass.uiColorFromHex(0xfc6c5f), forState: UIControlState.Selected)
            radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            radioButton.titleLabel?.numberOfLines = 3
            radioButton.titleLabel?.adjustsFontSizeToFitWidth = true
            let answers = Singleton.sharedInstance.answersProductQuestions
            if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
                if ans == possibleChoices[i] {
                    hasValue = true
                    radioButton.selected = true
                }
            }
            
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
        
        distance += screenSize.height/14
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4;
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
        
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        //        scrollView.contentOffset = CGPoint(x: screenSize.height / 100 , y: 0)
    }
    
    // Load checkbox questions (2)
    private func loadCheckBoxQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        distance = posY + h
        
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        // radio buttons
        var possibleChoices = q["choices"] as! [String]
        
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        // create radiobuttons from number of answers
        for var i = 0; i < possibleChoices.count; i++ {
            distance += 10
            var checkBox = MyRadioButton(frame: CGRectMake(posX, distance, w/1.5, screenSize.height/14))
            checkBox.setTitle(possibleChoices[i], forState: UIControlState.Normal)
            checkBox.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingHead
            checkBox.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            checkBox.setTitleColor(UtilityClass.uiColorFromHex(0xfc6c5f), forState: UIControlState.Selected)
            checkBox.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            checkBox.titleLabel?.numberOfLines = 3
            checkBox.titleLabel?.adjustsFontSizeToFitWidth = true
            let answers = Singleton.sharedInstance.answersProductQuestions
            if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? [String] {
                for var j = 0; j < ans.count; j++ {
                    if ans[j] == possibleChoices[i] {
                        hasValue = true
                        checkBox.selected = true
                    }
                }
            }
            
            scrollView.addSubview(checkBox)
            
            checkBox.addTarget(self, action:"checkboxButtonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
            checkBox.selectStateImage = "radiobutton-checked.png";
            checkBox.unselectStateImage = "radiobutton-unchecked.png";
            distance += screenSize.height/14
        }
        
        distance += screenSize.height/14
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        
    }
    // Load input number questions (3)
    private func loadSliderQuestion(q: NSDictionary) {
        
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        let tempMin = q["min"] as? String
        var minV  = (q["min"] as? NSString)!.floatValue
        let tempMax = q["max"] as? String
        var maxV  = (q["max"] as? NSString)!.floatValue
        
        sliderResultLabel = UILabel(frame: CGRectMake(posX, posY + distance, w/2, h))
        scrollView.addSubview(sliderResultLabel)
        sliderResultLabel.text = tempMin
        sliderResultLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        
        var slider = UISlider(frame: CGRectMake(posX + h, posY + distance, w - h, h))
        slider.minimumValue = minV
        slider.maximumValue = maxV
        slider.continuous = true
        slider.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        slider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        let answers = Singleton.sharedInstance.answersProductQuestions
        if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
            sliderResultLabel.text = ans
            slider.value = (ans as NSString).floatValue
            hasValue = true
        }
        
        distance += h + posY + h
        
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
        scrollView.addSubview(slider)
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load picker quetion (4)
    private func loadDropDownQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        var countryPicker = UIPickerView(frame: CGRectMake(posX, posY+h, w, h*4))
        
        let c = q["choices"] as! [String]
        //        for var i = 0; i < c.count; i++ {
        //           println(c[i])
        //        }
        
        choices = c
        countryPicker.delegate = self
        countryPicker.dataSource = self
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        let answers = Singleton.sharedInstance.answersProductQuestions
        if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
            var row = 0;
            for var i = 0; i < c.count; i++ {
                if c[i] == ans {
                    row = i
                }
            }
            countryPicker.selectRow(row, inComponent: 0, animated: true)
            hasValue = true
        }
        scrollView.addSubview(countryPicker)
        
        distance += posY + h*4
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
        
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load Input text field question (6)
    private func loadInputTextQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        var inputText = UITextField (frame:CGRectMake(posX, distance+10, w, h - h/4 ))
        inputText.borderStyle = UITextBorderStyle.Line
        inputText.layer.cornerRadius = 8.0
        inputText.layer.masksToBounds = true
        inputText.layer.borderColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        inputText.layer.borderWidth = 2.0
        inputText.keyboardType = UIKeyboardType.Default
        inputText.addTarget(self, action:"inputTextFieldListener:", forControlEvents: UIControlEvents.EditingChanged)
        let answers = Singleton.sharedInstance.answersProductQuestions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
            inputText.text = ans
            hasValue = true
        }
        
        scrollView.addSubview(inputText)
        
        distance += distance
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: 40)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: 40)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4;
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load Email quetion (7)
    private func loadEmailInputQuestion(q: NSDictionary) {
        
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        var emailinput = UITextField (frame:CGRectMake(posX, distance+10, w, h - h/4 ))
        emailinput.borderStyle = UITextBorderStyle.Line
        emailinput.layer.cornerRadius = 8.0
        emailinput.layer.masksToBounds = true
        emailinput.layer.borderColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        emailinput.layer.borderWidth = 2.0
        emailinput.keyboardType = UIKeyboardType.EmailAddress
        emailinput.addTarget(self, action:"emailFieldListenner:", forControlEvents: UIControlEvents.EditingChanged)
        let answers = Singleton.sharedInstance.answersProductQuestions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
            emailinput.text = ans
            hasValue = true
        }
        
        scrollView.addSubview(emailinput)
        
        distance += distance + h - h/4 + 10
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4;
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    
    // Load input number question (9)
    private func loadInputNumberQuestion(q:NSDictionary) {
        let w = screenSize.width - screenSize.width / 10
        let h = screenSize.height / 10
        
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        distance = posY + h
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        var numberInput = UITextField (frame:CGRectMake(posX, distance+10, w, h - h/4 ));
        numberInput.borderStyle = UITextBorderStyle.Line
        numberInput.layer.cornerRadius = 8.0
        numberInput.layer.masksToBounds = true
        numberInput.layer.borderColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        numberInput.layer.borderWidth = 2.0
        numberInput.keyboardType = UIKeyboardType.NumberPad
        numberInput.addTarget(self, action:"inputNumberFieldListner:", forControlEvents: UIControlEvents.EditingChanged)
        let answers = Singleton.sharedInstance.answersProductQuestions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentProductQNr] as? String {
            numberInput.text = ans
            hasValue = true
        }
        
        scrollView.addSubview(numberInput)
        
        distance += distance + h - h/4 + 10
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4;
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load barcode scanner view (10)
    func loadBarcodeScannerView(q:NSDictionary) {
        let vc : ScanViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
        vc.currentQuestionCategory = q
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    // Skip to some other question and restart from that question (11)
    func loadGotoQuestion(q:NSDictionary) {
        let count = q["gobackto"] as! String
        //TODO: Store the current result before going to a loop
        var answersProductQuestionsLoop = NSMutableDictionary()
        var i:Int = count.toInt()!
        var j = Singleton.sharedInstance.answersProductQuestions.count
        let answers = Singleton.sharedInstance.answersProductQuestions
        var k = 0
        while (i <= j) {
            if let ans: AnyObject = answers[i-1] {
                answersProductQuestionsLoop[k] = ans
                Singleton.sharedInstance.answersProductQuestions.removeObjectForKey(i-1)
            }
            i++
            k++
        }
        var s = "loop-" + Singleton.sharedInstance.loopCounter.description
        Singleton.sharedInstance.answersProductQuestions.setObject(answersProductQuestionsLoop, forKey: s)
        Singleton.sharedInstance.loopCounter++
        Singleton.sharedInstance.currentProductQNr = count.toInt()! - 1
        generateLayout()
    }
    
    // Load image selection question (12)
    func loadImageSelectionQuestion(q:NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
        let txt = q["questiondesc"] as? String
        scrollView.addSubview(generateLabel(txt!, xPosition: posX, yPosition: posY, width: w, height: h))
        
        if let popTitle = q["subtitle"] as? String {
            self.view.makeToast(message: popTitle, duration: 4, position: HRToastPositionCenter, title: "INFO")
        }
        
        distance = posY + h
        
        if let imageURL = q["imageURL"] as? String {
            let imageH = UIScreen.mainScreen().bounds.height / 3
            distance += 10
            var imageView = UIImageView(frame: CGRectMake(posX, distance, w, imageH))
            UtilityClass.loadImage(imageURL, imageView: imageView)
            scrollView.addSubview(imageView)
            distance += imageH
        }
        
        // radio buttons
        var possibleChoices = q["choices"] as! [String]
        
        // image sizes
        let imgW = (w - 10) / 2
        let imgH = h * 2
        
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        //        distance += 10
        // create radiobuttons from number of answers
        for var i = 0; i < possibleChoices.count; i++ {
            var imageView:UIImageView
            if i % 2 == 0 { // Left image
                if i != 0 {
                    distance += imgH // every 3rd image position
                }
                imageView = UIImageView(frame: CGRectMake(posX, distance, imgW, imgH))
                UtilityClass.loadImage(possibleChoices[i], imageView: imageView)
            } else { // right Image
                imageView = UIImageView(frame: CGRectMake(posX + imgW + 10, distance, imgW, imgH))
                UtilityClass.loadImage(possibleChoices[i], imageView: imageView)
            }
            imageView.contentMode = UIViewContentMode.ScaleAspectFit;
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageTapped:"))
            questionImages.append(imageView)
            scrollView.addSubview(imageView)
        }
        
        distance += imgH + 10
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: 40)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: 40)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4;
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        tickImage.contentMode = UIViewContentMode.ScaleAspectFit;
    }
    
    
    
    
    private func generateLabel(title: String, xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UILabel {
        var qLabel: UILabel = UILabel()
        qLabel.frame = CGRectMake(xPosition, yPosition, width, height)
        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        qLabel.numberOfLines = 4
        qLabel.backgroundColor = UIColor.orangeColor()
        qLabel.adjustsFontSizeToFitWidth = true
        qLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        qLabel.textAlignment = NSTextAlignment.Center
        qLabel.text = title
        qLabel.textColor = UIColor.whiteColor()
        addStyleShadow(qLabel)
        return qLabel
    }
    
    private func addStyleShadow(obj: AnyObject) {
        obj.layer.shadowColor = UIColor.blackColor().CGColor
        obj.layer.shadowOffset = CGSizeZero
        obj.layer.shadowOpacity = 0.5
        obj.layer.shadowRadius = 5
    }
    
    private func generateBackButton(xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UIButton {
        var backButton = UIButton(frame: CGRectMake(xPosition, yPosition, width, height))
        backButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        
        let mySelectedAttributedTitle = NSAttributedString(string: NSLocalizedString("back", comment: "Back"),
            attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        backButton.setAttributedTitle(mySelectedAttributedTitle, forState: UIControlState.Disabled)
        
        let myNormalAttributedTitle = NSAttributedString(string: NSLocalizedString("back", comment: "Back"),
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        backButton.setAttributedTitle(myNormalAttributedTitle, forState: UIControlState.Normal)
        
        backButton.setTitle(NSLocalizedString("back", comment: "Back"), forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        backButton.addTarget(self, action:"backButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addStyleShadow(backButton)
        if Singleton.sharedInstance.currentProductQNr == 0 {
            backButton.alpha = 0.4
        }
        return backButton
    }
    
    private func generateNextButton(xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UIButton {
        var nextButton = UIButton(frame: CGRectMake(xPosition, yPosition, width, height))
        nextButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        
        //        let mySelectedAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next"),
        //            attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        //        nextButton.setAttributedTitle(mySelectedAttributedTitle, forState: UIControlState.Disabled)
        //
        //        let myNormalAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next"),
        //            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        //        nextButton.setAttributedTitle(myNormalAttributedTitle, forState: UIControlState.Normal)
        
        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), forState: UIControlState.Normal)
        nextButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        nextButton.addTarget(self, action:"nextButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        nextButton.showsTouchWhenHighlighted = true
        nextButton.alpha = 0.4
        addStyleShadow(nextButton)
        return nextButton
    }
    
    func inputNumberFieldListner(sender:UITextField) {
        if (count(sender.text!) > 4) {
            sender.deleteBackward()
        }
        if let intVal = sender.text.toInt() {
            Singleton.sharedInstance.answersProductQuestions.setObject(sender.text, forKey: Singleton.sharedInstance.currentProductQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {  // if you subclass UIImageView, then change "UIImageView" to your
            for var i = 0; i < questionImages.count; i++ {
                if imageView == questionImages[i] {
                    Singleton.sharedInstance.answersProductQuestions.setObject(i+1, forKey: Singleton.sharedInstance.currentProductQNr)
                }
            }
            tickImage.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width/3, imageView.frame.size.height/3)
            tickImage.image = UIImage(named: "check.png")
            nextButton.enabled = true
            nextButton.alpha = 1.0
            scrollView.addSubview(tickImage)
            
        }
        
        
    }
    
    func inputTextFieldListener(sender:UITextField) {
        if let txt = sender.text {
            Singleton.sharedInstance.answersProductQuestions.setObject(sender.text as String,
                forKey: Singleton.sharedInstance.currentProductQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        let v = Int(sender.value).description
        nextButton.enabled = true
        nextButton.alpha = 1.0
        sliderResultLabel.text = v
        Singleton.sharedInstance.answersProductQuestions.setObject(v, forKey: Singleton.sharedInstance.currentProductQNr)
    }
    
    func emailFieldListenner(sender:UITextField) {
        if (UtilityClass.isValidEmail(sender.text as String) == true) {
            sender.textColor = UIColor.blackColor()
            sender.backgroundColor = UtilityClass.uiColorFromHex(0xdfffde)
            Singleton.sharedInstance.answersProductQuestions.setObject(sender.text as String,
                forKey: Singleton.sharedInstance.currentProductQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
        } else {
            nextButton.enabled = false
            nextButton.alpha = 0.4
            sender.backgroundColor = UIColor.blackColor()
        }
    }
    
    func radioButtonSelected(sender:MyRadioButton) {
        if let text = sender.titleLabel?.text {
            Singleton.sharedInstance.answersProductQuestions.setObject(text,
                forKey: Singleton.sharedInstance.currentProductQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
            println(Singleton.sharedInstance.answersProductQuestions[Singleton.sharedInstance.currentProductQNr])
        }
    }
    
    func checkboxButtonSelected(sender:MyRadioButton) {
        
        if let text = sender.titleLabel?.text {
            println(text)
            if var possibleAnswersList: [String] = Singleton.sharedInstance.answersProductQuestions[Singleton.sharedInstance.currentProductQNr] as? [String] {
                var index = 0
                var found = false
                for var i = 0; i < possibleAnswersList.count; i++ {
                    if possibleAnswersList[i] == text {
                        index = i
                        found = true
                    }
                }
                if found {
                    possibleAnswersList.removeAtIndex(index)
                } else {
                    possibleAnswersList.append(text)
                }
                Singleton.sharedInstance.answersProductQuestions.setObject(possibleAnswersList, forKey: Singleton.sharedInstance.currentProductQNr)
                if possibleAnswersList.count > 0 {
                    nextButton.enabled = true
                    nextButton.alpha = 1.0
                } else {
                    nextButton.enabled = false
                    nextButton.alpha = 0.4
                }
            } else {
                let possibleAnswers:[String] = [text]
                if possibleAnswers.count > 0 {
                    nextButton.enabled = true
                    nextButton.alpha = 1.0
                } else {
                    nextButton.enabled = false
                    nextButton.alpha = 0.4
                }
                Singleton.sharedInstance.answersProductQuestions.setObject(possibleAnswers, forKey: Singleton.sharedInstance.currentProductQNr)
            }
            
        }
        var possibleAnswers: [String] = (Singleton.sharedInstance.answersProductQuestions[Singleton.sharedInstance.currentProductQNr] as? [String])!
        if possibleAnswers.count > 0 {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        } else {
            nextButton.enabled = false
            nextButton.alpha = 0.4
        }
        
    }
    
    private func nextQuestionCondition() {
        //        self.view.makeToast(message: "Done")
        if Singleton.sharedInstance.currentProductQNr < questions.count-1 {
            
            Singleton.sharedInstance.currentProductQNr++
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            generateLayout()
        } else {
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            let answers = Singleton.sharedInstance.answersProductQuestions
            for (key, value) in answers {
                println("Key: \(key) \(value)")
            }
            
            let txt = NSLocalizedString("thank_you_participate", comment: "Personal Question")
            let w = screenSize.width - screenSize.width / 10
            let h = screenSize.height / 10
            // Reset the questionarire
            Singleton.sharedInstance.currentProductQNr = 0
            
            let posY = screenSize.height / 2 - h
            let posX = (screenSize.width - w) / 2
            var timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
            scrollView.addSubview(generateLabel(txt, xPosition: posX, yPosition: posY, width: w, height: h))
        }
    }
    
    func update() {
        // Reset the questionarire
        Singleton.sharedInstance.currentProductQNr = 0
        
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("FeedbackViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    func backButtonPressed(sender:UIButton) {
        // Except first questio
        if Singleton.sharedInstance.currentProductQNr != 0 {
            
            // go back to two postion, current position corrispond to the next question
            // so have to go back two position
            Singleton.sharedInstance.doneProductQuestionPosition -= 2
            var position = Singleton.sharedInstance.doneProductQuestionPosition
            
            if Singleton.sharedInstance.currentProductQNr > 0 {
                
                let backQuesionID = Singleton.sharedInstance.doneProductQuestions[position]
                
                // Remove all the result of the answered question when move to back position
                let temp = Singleton.sharedInstance.currentProductQNr
                let diffID = temp - backQuesionID
                for var i = temp; i > backQuesionID; i-- {
                    let a1 = Singleton.sharedInstance.answersProductQuestions.count
                    Singleton.sharedInstance.answersProductQuestions.removeObjectForKey(i)
                    let a2 = Singleton.sharedInstance.answersProductQuestions.count
                    println(a1)
                    println(a2)
                }
                
                println(diffID)
                
                // If the backquestion is go to question have to go back once again
                let question = questions[backQuesionID] as! NSMutableDictionary
                if let value = question["typeid"] as? String {
                    if value == "11" {
                        Singleton.sharedInstance.doneProductQuestionPosition -= 1
                        position = Singleton.sharedInstance.doneProductQuestionPosition
                    }
                }
                
                Singleton.sharedInstance.currentProductQNr = Singleton.sharedInstance.doneProductQuestions[position]
                // var k = Singleton.sharedInstance.currentProductQNr
                
                for view in scrollView.subviews {
                    view.removeFromSuperview()
                }
                generateLayout()
            }
        }
    }
    
    func nextButtonPressed(sender:UIButton) {
        nextQuestionCondition()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //////////// PICKERVIEW DELEATE AND SOURCE /////////////////////////////////
    //MARK -Delgates and DataSource
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return choices[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Singleton.sharedInstance.answersProductQuestions.setObject(choices[row], forKey: Singleton.sharedInstance.currentProductQNr)
        if let label = pickerView.viewForRow(row, forComponent: component) as? UILabel {
            label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        }
        nextButton.enabled = true
        nextButton.alpha = 1.0
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = choices[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            
            //color  and center the label's background
            //            let hue = CGFloat(row)/CGFloat(countries.count)
            //            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.backgroundColor = UIColor.whiteColor()
            pickerLabel.adjustsFontSizeToFitWidth = true
            pickerLabel.textAlignment = .Center
        }
        let titleData = choices[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        //        answers.setObject(titleData, forKey: count)
        
        
        return pickerLabel
        
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
}