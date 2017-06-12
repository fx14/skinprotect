//
//  PersonalQuestionViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 21/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import CoreData


class PersonalQuestionViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Contains all questions parsed from XML
    private var questions = NSMutableArray()
    private var choices:[String] = []
    
    private var tickImage = UIImageView()
    private var questionImages:[UIImageView] = []
    
    private var sliderResultLabel = UILabel()
    private var nextButton = UIButton();
    private var backButton = UIButton();
    
    // Contains answers
    private var answers = NSMutableDictionary()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    let w = UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 10
    let h = UIScreen.mainScreen().bounds.height / 8
    
    
    var max = 0
    var min = 0
    
    enum PickerComponent:Int {
        case size = 0
        case topping = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height)
        
        // set title screen
        self.title = NSLocalizedString("personal_question", comment: "Personal Questions")
        
        
        let image = UIImage(named:"home.png") as UIImage!
        var btnBack:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btnBack.addTarget(self, action: "homeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(image, forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        
        let xmlAnalyzer = XMLPersonalQuestionsAnalyzer()
        questions = xmlAnalyzer.beginParsingXML("personal")
        generateLayout()
        scrollView.layer.shadowColor = UIColor.blackColor().CGColor
        scrollView.layer.shadowOffset = CGSizeZero
        scrollView.layer.shadowOpacity = 0.5
        scrollView.layer.shadowRadius = 5
        
        var mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size //
        var imageObbj:UIImage! =   UtilityClass.imageResize(UIImage(named: "wood_backgroud.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        self.view.backgroundColor = UIColor(patternImage:imageObbj)
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
        let count = Singleton.sharedInstance.currentPersoalQNr
        let question = questions[count] as! NSMutableDictionary
        var isNextQuestion = true
        
        // Load the parent question id
        if let parentQuestionID = question["parentquestionID"] as? [String] {
            // Load the parent question result
            if let parentQuestionValue = question["valuecondition"] as? [String] {
                // Load all parent questions
                for var i = 0; i < parentQuestionID.count; i++ {
                    // Load the answer
                    let answers = Singleton.sharedInstance.answersPersonalQuetions
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
            radioButton.setTitle(possibleChoices[i], forState: UIControlState.Normal)
            radioButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingHead
            radioButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            radioButton.setTitleColor(UtilityClass.uiColorFromHex(0xfc6c5f), forState: UIControlState.Selected)
            radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            radioButton.titleLabel?.numberOfLines = 3
            radioButton.titleLabel?.adjustsFontSizeToFitWidth = true
            let answers = Singleton.sharedInstance.answersPersonalQuetions
            if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
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
            nextButton.alpha = 0.4
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load checkbox questions (2)
    private func loadCheckBoxQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
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
            checkBox.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            checkBox.setTitleColor(UtilityClass.uiColorFromHex(0xfc6c5f), forState: UIControlState.Selected)
            checkBox.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            checkBox.titleLabel?.numberOfLines = 3
            checkBox.titleLabel?.adjustsFontSizeToFitWidth = true
            let answers = Singleton.sharedInstance.answersPersonalQuetions
            if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? [String] {
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
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        
    }
    // Load input number questions (3)
    private func loadSliderQuestion(q: NSDictionary) {
        
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
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
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
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
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        scrollView.addSubview(slider)
    }
    
    // Load picker quetion (4)
    private func loadDropDownQuestion(q: NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
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
        
        var countryPicker = UIPickerView(frame: CGRectMake(posX, posY+h, w, h*4))
        
        let c = q["choices"] as! [String]
        choices = c
        countryPicker.delegate = self
        countryPicker.dataSource = self
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
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
        
        distance +=  posY + h*4
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
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
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
            inputText.text = ans
            hasValue = true
        }
        
        scrollView.addSubview(inputText)
        
        distance += h + posY + h - h/4 + 10
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: 40)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: 40)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
    }
    
    // Load Email quetion (7)
    private func loadEmailInputQuestion(q: NSDictionary) {
        
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25 + h
        
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
        emailinput.textColor = UIColor.whiteColor()
        emailinput.layer.borderColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        emailinput.layer.borderWidth = 2.0
        emailinput.keyboardType = UIKeyboardType.EmailAddress
        emailinput.addTarget(self, action:"emailFieldListenner:", forControlEvents: UIControlEvents.EditingChanged)
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
            emailinput.text = ans
            hasValue = true
        }
        
        scrollView.addSubview(emailinput)
        
        distance += h + posY + h - h/4
        var nPosX = (screenSize.width - w - 10) / 2
        backButton = generateBackButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        nPosX = nPosX + w/2 + 10
        nextButton = generateNextButton(nPosX, yPosition: distance, width: w/2, height: screenSize.height/14)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(backButton)
        if !hasValue {
            nextButton.enabled = false
            nextButton.alpha = 0.4
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
        
        if let tempMin = q["min"] as? String {
            if let m:Int = tempMin.toInt() {
                min = m
            }
        } else {
            min = 0
        }
        if let tempMax = q["max"] as? String {
            if let m:Int = tempMax.toInt() {
                max = m
            }
        } else {
            max = 0
        }
        
        
        var numberInput = UITextField (frame:CGRectMake(posX, distance+10, w, h - h/4 ));
        numberInput.borderStyle = UITextBorderStyle.Line
        numberInput.layer.cornerRadius = 8.0
        numberInput.textColor = UIColor.whiteColor()
        numberInput.layer.masksToBounds = true
        numberInput.layer.borderColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        numberInput.layer.borderWidth = 2.0
        numberInput.keyboardType = UIKeyboardType.NumberPad
        numberInput.addTarget(self, action:"inputNumberFieldListner:", forControlEvents: UIControlEvents.EditingChanged)
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        if let ans = answers[Singleton.sharedInstance.currentPersoalQNr] as? String {
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
            nextButton.alpha = 0.4
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
        var answersPersonalQuetionsLoop = NSMutableDictionary()
        var i:Int = count.toInt()!
        var j = Singleton.sharedInstance.answersPersonalQuetions.count
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        var k = 0
        while (i <= j) {
            if let ans: AnyObject = answers[i-1] {
                answersPersonalQuetionsLoop[k] = ans
                Singleton.sharedInstance.answersPersonalQuetions.removeObjectForKey(i-1)
            }
            i++
            k++
        }
        var s = "loop-" + Singleton.sharedInstance.loopCounter.description
        Singleton.sharedInstance.answersPersonalQuetions.setObject(answersPersonalQuetionsLoop, forKey: s)
        Singleton.sharedInstance.loopCounter++
        Singleton.sharedInstance.currentPersoalQNr = count.toInt()! - 1
        generateLayout()
    }
    
    // Load image selection question (12)
    func loadImageSelectionQuestion(q:NSDictionary) {
        let posY = screenSize.height / 100
        let posX = (screenSize.width - w) / 2
        var distance = screenSize.height / 25
        
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
        
        // image sizes
        let imgW = (w - 10) / 2
        let imgH = h * 2.5
        
        
        // variable that check if already an answers has been gave to the question
        var hasValue = false
        distance += 10
        // create radiobuttons from number of answers
        for var i = 0; i < possibleChoices.count; i++ {
            var imageView:UIImageView
            if i % 2 == 0 { // Left image
                if i != 0 {
                    distance += imgH + 10 // every 3rd image position
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
            nextButton.alpha = 0.4
        }
        distance += screenSize.height/14 + 20
        scrollView.contentSize = CGSizeMake(screenSize.width, distance)
        tickImage.contentMode = UIViewContentMode.ScaleAspectFit;
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
        return qLabel
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
        
        if Singleton.sharedInstance.currentPersoalQNr == 0 {
            backButton.alpha = 0.4
        }
        return backButton
    }
    
    private func generateNextButton(xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat) -> UIButton {
        var nextButton = UIButton(frame: CGRectMake(xPosition, yPosition, width, height))
        nextButton.backgroundColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        
        let mySelectedAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next"),
            attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        nextButton.setAttributedTitle(mySelectedAttributedTitle, forState: UIControlState.Disabled)
        
        let myNormalAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next"),
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        nextButton.setAttributedTitle(myNormalAttributedTitle, forState: UIControlState.Normal)
        
        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), forState: UIControlState.Normal)
        nextButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        nextButton.addTarget(self, action:"nextButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.showsTouchWhenHighlighted = true
        
        return nextButton
    }
    
    func inputNumberFieldListner(sender:UITextField) {
        if (count(sender.text!) > 4) {
            sender.deleteBackward()
        }
        if let intVal = sender.text.toInt() {
            if min != 0 && max != 0 {
                if intVal >= min && intVal <= max {
                    Singleton.sharedInstance.answersPersonalQuetions.setObject(sender.text, forKey: Singleton.sharedInstance.currentPersoalQNr)
                    nextButton.enabled = true
                    nextButton.alpha = 1.0
                } else {
                    nextButton.enabled = false
                    nextButton.alpha = 0.4
                    self.view.makeToast(message: "1915-2015", duration: 1, position: HRToastPositionCenter, title: "INFO")
                }
            } else {
                Singleton.sharedInstance.answersPersonalQuetions.setObject(sender.text, forKey: Singleton.sharedInstance.currentPersoalQNr)
                nextButton.enabled = true
                nextButton.alpha = 1.0
            }
        }
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        let v = Int(sender.value).description
        nextButton.enabled = true
        nextButton.alpha = 1.0
        sliderResultLabel.textColor = UIColor.whiteColor()
        sliderResultLabel.text = v
        Singleton.sharedInstance.answersPersonalQuetions.setObject(v, forKey: Singleton.sharedInstance.currentPersoalQNr)
    }
    
    
    func inputTextFieldListener(sender:UITextField) {
        if let txt = sender.text {
            Singleton.sharedInstance.answersPersonalQuetions.setObject(sender.text as String,
                forKey: Singleton.sharedInstance.currentPersoalQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
    }
    
    func emailFieldListenner(sender:UITextField) {
        if (UtilityClass.isValidEmail(sender.text as String) == true) {
            sender.textColor = UIColor.blackColor()
            sender.backgroundColor = UtilityClass.uiColorFromHex(0xdfffde)
            Singleton.sharedInstance.answersPersonalQuetions.setObject(sender.text as String,
                forKey: Singleton.sharedInstance.currentPersoalQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
        } else {
            nextButton.enabled = false
            nextButton.alpha = 0.4
            nextButton.alpha = 0.4
            sender.backgroundColor = UIColor.blackColor()
        }
    }
    
    func radioButtonSelected(sender:MyRadioButton) {
        if let text = sender.titleLabel?.text {
            Singleton.sharedInstance.answersPersonalQuetions.setObject(text,
                forKey: Singleton.sharedInstance.currentPersoalQNr)
            nextButton.enabled = true
            nextButton.alpha = 1.0
            
            println(Singleton.sharedInstance.answersPersonalQuetions[Singleton.sharedInstance.currentPersoalQNr])
        }
    }
    
    func checkboxButtonSelected(sender:MyRadioButton) {
        if let text = sender.titleLabel?.text {
            if var possibleAnswers: [String] = Singleton.sharedInstance.answersPersonalQuetions[Singleton.sharedInstance.currentPersoalQNr] as? [String] {
                var index = 0
                var found = false
                for var i = 0; i < possibleAnswers.count; i++ {
                    if possibleAnswers[i] == text {
                        index = i
                        found = true
                    }
                }
                if found {
                    possibleAnswers.removeAtIndex(index)
                } else {
                    possibleAnswers.append(text)
                }
                Singleton.sharedInstance.answersPersonalQuetions.setObject(possibleAnswers, forKey: Singleton.sharedInstance.currentPersoalQNr)
                if possibleAnswers.count > 0 {
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
                Singleton.sharedInstance.answersPersonalQuetions.setObject(possibleAnswers, forKey: Singleton.sharedInstance.currentPersoalQNr)
            }
            
        }
    }
    
    
    private func nextQuestionCondition() {
        //        self.view.makeToast(message: "Done")
        if Singleton.sharedInstance.currentPersoalQNr < questions.count-1 {
            Singleton.sharedInstance.currentPersoalQNr++;
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            generateLayout()
        } else {
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            let answers = Singleton.sharedInstance.answersPersonalQuetions
            for (key, value) in answers {
                println("Key: \(key) \(value)")
            }
            
            let txt = NSLocalizedString("start_product_question", comment: "Start Product Question")
            let w = screenSize.width - screenSize.width / 10
            let h = screenSize.height / 10
            
            let posY = screenSize.height / 2 - h
            let posX = (screenSize.width - w) / 2
            
            var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
            
            scrollView.addSubview(generateLabel(txt, xPosition: posX, yPosition: posY, width: w, height: h))
        }
    }
    
    func update() {
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue("1", forKey: "personal_question")
                managedObjectContext!.save(nil)
            }
        }
        
        let answers = Singleton.sharedInstance.answersPersonalQuetions
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "PersonalQuestion")
        var result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        
        
        // Insert new raw
        var perQ = NSEntityDescription.insertNewObjectForEntityForName("PersonalQuestion",
            inManagedObjectContext: managedObjectContext!) as! PersonalQuestion
        
        perQ.gender = ""
        perQ.age = ""
        perQ.height = ""
        perQ.weight = ""
        perQ.nationality = ""
        perQ.zip = ""
        perQ.education = ""
        perQ.skin_allergy = ""
        perQ.body_part = ""
        perQ.doctor_contact = ""
        perQ.contact = ""
        perQ.email = ""
        // Save personal queston to the database
        for (key, value) in answers {
            if let keyString:Int = key as? Int {
                switch keyString {
                case 0:
                    let v = (value as? String)!
                    perQ.gender = v
                case 1:
                    let year = (value as? String)!
                    let age = 2015 - year.toInt()!
                    perQ.age = age.description
                case 2:
                    let v = (value as? String)!
                    perQ.height = v
                case 3:
                    let v = (value as? String)!
                    perQ.weight = v
                case 4:
                    let v = (value as? String)!
                    perQ.nationality = v
                case 5:
                    let v = (value as? String)!
                    perQ.zip = v
                case 6:
                    let v = (value as? String)!
                    perQ.education = v
                case 7:
                    let v = (value as? String)!
                    perQ.skin_allergy = v
                case 8:
                    let v = (value as? [String])!
                    var txt = ""
                    for str in v {
                        txt += str + ", "
                    }
                    perQ.body_part = txt
                case 9:
                    let v = (value as? String)!
                    perQ.doctor_contact = v
                case 10:
                    let v = (value as? String)!
                    perQ.contact = v
                case 11:
                    let v = (value as? String)!
                    perQ.contact = v
                case 12:
                    let v = (value as? String)!
                    perQ.email = v
                default:
                    println()
                }
            }
        }
        
        if !managedObjectContext!.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        result = managedObjectContext!.executeFetchRequest(fReq, error:&error)
        
        
        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ProductQuestionViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    
    func backButtonPressed(sender:MyRadioButton) {
        if Singleton.sharedInstance.currentPersoalQNr > 0 {
            Singleton.sharedInstance.currentPersoalQNr--;
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            generateLayout()
        }
    }
    
    func nextButtonPressed(sender:MyRadioButton) {
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
        Singleton.sharedInstance.answersPersonalQuetions.setObject(choices[row], forKey: Singleton.sharedInstance.currentPersoalQNr)
        if let label = pickerView.viewForRow(row, forComponent: component) as? UILabel {
            label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        }
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
        nextButton.enabled = true
        nextButton.alpha = 1.0
        
        return pickerLabel
        
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
    
    //    private func loadRadioButton(q: NSDictionary) {
    //        var qLabel: UILabel = UILabel()
    //        let w = screenSize.width - screenSize.width / 10
    //        let h = screenSize.height / 10
    //        let posY = screenSize.height / 6
    //        let posX = (screenSize.width - w) / 2
    //        //        qLabel.frame = CGRectMake(posX, posY, w, h)
    //        qLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    //        qLabel.numberOfLines = 3
    //        qLabel.backgroundColor = UIColor.orangeColor()
    //        qLabel.textColor = UIColor.blackColor()
    //        qLabel.textAlignment = NSTextAlignment.Center
    //        qLabel.text = q["questiondesc"] as? String
    //        qLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    //
    //        view.addSubview(qLabel)
    //
    //        var viewsDictionary = ["qLable":qLabel]
    //        var metricsDictionary = ["qLableHeight":h, "qLableWidth":w]
    //
    //        // radio buttons
    //        var answers:[String] = q["choices"] as [String]
    //        for var index = 0; index > answers.count; index++ {
    //            var choiceRadio:MyRadioButton = MyRadioButton()
    //            let title = "choice" + index.description
    //            viewsDictionary[title] = choiceRadio.description
    //        }
    //
    //
    //
    //
    //
    //        //sizing constraints
    //        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-"+posX.description+"-[qLable(qLableWidth)]", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
    //        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-"+posY.description+"-[qLable(qLableHeight)]", options: NSLayoutFormatOptions.AlignAllLeading, metrics: metricsDictionary, views: viewsDictionary)
    //
    //
    //
    //        view.addConstraints(view_constraint_H)
    //        view.addConstraints(view_constraint_V)
    //
    //    }
    
    
    
    //
    // radio buttons
    //    var answers = q["choices"] as [String]
    //    var radioButtons:[UISwitch] = []
    //    let s = "asda"
    //    distance = posY + h
    //    for var i = 0; i < answers.count; i++ {
    //    var t = distance * CGFloat(i + 1)
    //    println(distance)
    //    var switchRadio = UISwitch(frame: CGRectMake(posX, posY + t, 0, 0))
    //    radioButtons.append(switchRadio)
    //    scrollView.addSubview(switchRadio)
    
    
    
}


