//
//  ProductDetailViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 21/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit


class ProductDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDelegate {
    
    
    var barcode:String = ""
    var categories:[String] = []
    var selectedCategory:String = ""
    private var isConnectedToDatabase = false
    private var productDetails = NSMutableDictionary()
    var currentQuestionCategory:NSDictionary = NSDictionary()
    
    var bytes:NSMutableData?
    
    @IBOutlet weak var pickerCategoryView: UIPickerView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var activityImageIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityTextIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var codecheckPoweredByText: UILabel!
    
    enum PickerComponent:Int {
        case size = 0
        case topping = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityImageIndicatorView.startAnimating()
        activityTextIndicatorView.startAnimating()
        self.activityTextIndicatorView.hidesWhenStopped = true
        
        // set title screen
        self.title = NSLocalizedString("product_detail", comment: "Product Detail")
        codecheckPoweredByText.text = NSLocalizedString("by_codecheck", comment: "By Codecheck")
        
        if Reachability.isConnectedToNetwork() {
            connectSynchrnousProductDatabase()
        } else {
            loadInternetConnectionAlertPopup();
        }
        categories = currentQuestionCategory["choices"] as! [String]
        //        categories = XMLProductCategoryAnalyzer().beginParsingXML()
        
        
        pickerCategoryView.delegate = self
        pickerCategoryView.dataSource = self
        nextButton.enabled = false
        nextButton.alpha = 0.4
        
        if categories.count  <= 1 {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
        
        let mySelectedAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next Button"),
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        nextButton.setAttributedTitle(mySelectedAttributedTitle, forState: UIControlState.Disabled)
        let myNormalAttributedTitle = NSAttributedString(string: NSLocalizedString("next", comment: "Next Button"),
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
       
        nextButton.setAttributedTitle(myNormalAttributedTitle, forState: UIControlState.Normal)
        
        nextButton.setTitle(NSLocalizedString("next", comment: "Next Button"), forState: .Normal)
        self.productImageView.image = UIImage(named: "noimage.jpg")
        
    }
    
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
            connectSynchrnousProductDatabase()
        } else {
            ////            let m = NSLocalizedString("connect_to_internet", comment: "Please connect to the internet")
            ////            var alert = UIAlertController(title: "", message: m, preferredStyle: UIAlertControllerStyle.Alert)
            ////            alert.view.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
            ////            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: self.checkInternetConnection))
            ////            self.presentViewController(alert, animated: true, completion: nil)
            //
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
    }
    
    
    
    func connectSynchrnousProductDatabase() {
        let urlPath: String = "http://api.autoidlabs.ch/test/" + barcode
        var url: NSURL = NSURL(string: urlPath)!
        var request1: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var error: NSErrorPointer = nil
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
        var err: NSError
        println(response)
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        if let codeCheckJson = jsonResult["codecheckJson"] as? NSDictionary {
            if let members = codeCheckJson["members"] as? NSDictionary {
                if let name = members["name"] as? String {
                    self.productNameLabel.text = name
                    self.productDetails.setObject(name, forKey: "product_name")
                    self.activityTextIndicatorView.stopAnimating()
                    self.isConnectedToDatabase = true
                    nextButton.enabled = true
                    nextButton.alpha = 1.0
                }
                if let imageID = members["imgId"] as? CLong {
                    let imgUrl = "http://api.autoidlabs.ch/image/" + imageID.description
                    self.productDetails.setObject(imgUrl, forKey: "image_link")
                    self.loadImage(imgUrl)
                    nextButton.enabled = true
                    nextButton.alpha = 1.0
                }
            }
        } else {
            self.productNameLabel.text = NSLocalizedString("product_not_identified", comment: "Product not identified")
            println("Product not identified")
            self.productImageView.image = UIImage(named: "noimage.jpg")
            self.isConnectedToDatabase = true
            self.nextButton.enabled = true
            self.activityTextIndicatorView.stopAnimating()
            self.activityImageIndicatorView.stopAnimating()
        }
//        println("Synchronous\(jsonResult)")
    }
    
    func connectAsynchronousProductDatabase() {
        let urlString = "http://api.autoidlabs.ch/test/" + barcode
        println(urlString)
        let url: NSURL = NSURL(string: urlString)!
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = url
        request.HTTPMethod = "GET"
        
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
            (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: NSError?
            if let result = NSJSONSerialization.JSONObjectWithData(data, options:  NSJSONReadingOptions.MutableContainers, error: &error)
                as? NSDictionary {
                    if let codeCheckJson = result["codecheckJson"] as? NSDictionary {
                        if let members = codeCheckJson["members"] as? NSDictionary {
                            if let name = members["name"] as? String {
                                self.productNameLabel.text = name
                                self.productDetails.setObject(name, forKey: "product_name")
                                self.activityTextIndicatorView.stopAnimating()
                                self.isConnectedToDatabase = true
                                self.nextButton.enabled = true
                                self.nextButton.alpha = 1.0
                            }
                            if let imageID = members["imgId"] as? CLong {
                                let imgUrl = "http://api.autoidlabs.ch/image/" + imageID.description
                                self.productDetails.setObject(imgUrl, forKey: "image_link")
                                self.loadImage(imgUrl)
                            }
                        }
                    } else {
                        self.productNameLabel.text = NSLocalizedString("product_not_identified", comment: "Product not identified")
                        println("Product not identified")
                        self.productImageView.image = UIImage(named: "noimage.jpg")
                        self.isConnectedToDatabase = true
                        self.nextButton.enabled = true
                        self.nextButton.alpha = 1.0
                        self.activityTextIndicatorView.stopAnimating()
                        self.activityImageIndicatorView.stopAnimating()
                    }
                    
                    
            } else {
                self.productNameLabel.text = NSLocalizedString("product_not_identified", comment: "Product not identified")
                self.productImageView.image = UIImage(named: "noimage.jpg")
                let resultString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Flawed JSON String: \(resultString)")
            }
        })
      
    }
    
    func loadImage (imageLink: String) {
        var imgURL: NSURL = NSURL(string: imageLink)!
        
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var image = UIImage(data: data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.productImageView.image = image
                    self.activityImageIndicatorView.stopAnimating()
                })
            } else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            // Check if the connection to database is done
            if !isConnectedToDatabase {
                connectSynchrnousProductDatabase()
            } else {
                productDetails.setObject(barcode, forKey: "barcode")
                var isExist:Bool = false
                for product in Singleton.sharedInstance.currentProductsDetails {
                    if barcode == product["barcode"] as! String {
                        isExist = true
                    }
                }
                if !isExist {
                    Singleton.sharedInstance.currentProductsDetails.append(productDetails)
                    var value:String = barcode + ", " + selectedCategory
                    println ("category value (ProductDetailViewController): " + value)
                    Singleton.sharedInstance.answersProductQuestions.setObject(value, forKey: Singleton.sharedInstance.currentProductQNr)
                }
                
                let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ProductQuestionViewController")
                self.showViewController(vc as! UIViewController, sender: vc)
                Singleton.sharedInstance.currentProductQNr++
            }
        } else {
            self.view.makeToast(message: NSLocalizedString("connect_to_internet", comment: "Please connect to the internet"))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    //////////// PICKERVIEW DELEATE AND SOURCE /////////////////////////////////
    //MARK -Delgates and DataSource
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return categories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        nextButton.enabled = true
        nextButton.alpha = 1.0
        self.productDetails.setObject(categories[row], forKey: "category")
        if let label = pickerView.viewForRow(row, forComponent: component) as? UILabel {
            label.textColor = UtilityClass.uiColorFromHex(0xfc6c5f)
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = categories[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            pickerLabel.backgroundColor = UIColor.whiteColor()
            pickerLabel.adjustsFontSizeToFitWidth = true
            pickerLabel.textAlignment = .Center
        }
        let titleData = categories[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
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