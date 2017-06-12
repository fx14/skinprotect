//
//  ScanViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 16/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes

class ScanViewController: RSCodeReaderViewController {
    
    private var barcodeFound = false
    private var barcodeNumber: String = ""
    var currentQuestionCategory:NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title screen
        self.title = NSLocalizedString("scan_controller_title", comment: "Scan Product")
        self.navigationItem.setHidesBackButton(false, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        self.cornersLayer.strokeColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        
        let txt = currentQuestionCategory["questiondesc"] as? String
        //NSLocalizedString("scan_a_barcode", comment: "Please scan a barcode")
        self.view.makeToast(message: txt!, duration: 3, position: HRToastPositionCenter, title: "INFO")
        
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        myBackButton.addTarget(self, action: "backButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        self.tapHandler = { point in
            println(point)
        }
        
        // Scan code
        scanProcess()
        
        
        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
        types.removeObject(AVMetadataObjectTypeQRCode)
        self.output.metadataObjectTypes = NSArray(array: types) as [AnyObject]
        
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview as! UIView)
        }
        
    }
    
    func backButtonPressed(sender:UIButton) {
        Singleton.sharedInstance.doneProductQuestionPosition -= 2
        let position = Singleton.sharedInstance.doneProductQuestionPosition
        if Singleton.sharedInstance.currentProductQNr > 0 {
            var t = Singleton.sharedInstance.doneProductQuestions[position]
            Singleton.sharedInstance.currentProductQNr = Singleton.sharedInstance.doneProductQuestions[position]
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ProductQuestionViewController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    func scanProcess() {
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                
                if (!self.barcodeFound) {
                    self.barcodeFound = true
                    self.barcodeNumber = barcode.stringValue
                    
                    var alert = UIAlertController(title: self.barcodeNumber, message: NSLocalizedString("barcode", comment: "Barcode"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.view.tintColor = UtilityClass.uiColorFromHex(0xfc6c5f)
                    alert.addAction(UIAlertAction(title: "Re-Scan", style: UIAlertActionStyle.Default, handler: self.rescan))
                    alert.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.Default, handler: self.loadController))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func toggleFlash(sender: UIButton) {
        session.beginConfiguration()
        device.lockForConfiguration(nil)
        
        if device.torchMode == AVCaptureTorchMode.Off {
            device.torchMode = AVCaptureTorchMode.On
        } else if device.torchMode == AVCaptureTorchMode.On {
            device.torchMode = AVCaptureTorchMode.Off
        }
        
        device.unlockForConfiguration()
        session.commitConfiguration()
    }
    
    
    // load product detail view controller
    func loadController(alert: UIAlertAction!) {
        //TODO: check if the barcode is already exist
        
        let vc : ProductDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProductDetailView") as! ProductDetailViewController
        vc.barcode = barcodeNumber
        vc.currentQuestionCategory = currentQuestionCategory
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    // start the scanning operation
    func rescan(alert: UIAlertAction!) {
        self.barcodeFound = false
        scanProcess()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.barcodeFound = false
        self.navigationController?.navigationBarHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

