//
//  ScanIdentifier.swift
//  Survey
//
//  Created by Charles Balachandran on 07/04/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes
import CoreData

class ScanIdentifier: RSCodeReaderViewController {
    
    private var barcodeFound = false
    private var barcodeNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title screen
        self.title = NSLocalizedString("scan_identifier", comment: "Scan identifier")
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        self.cornersLayer.strokeColor = UtilityClass.uiColorFromHex(0xfc6c5f).CGColor
        
        self.tapHandler = { point in
            println(point)
        }
        
        // Scan code
        scanProcess()
        
//         self.view.makeToast(message: NSLocalizedString("connect_to_internet", comment: "Please connect to the internet"))
        let txt = NSLocalizedString("scan_a_barcode", comment: "Please scan a barcode")
        self.view.makeToast(message: txt, duration: 3, position: HRToastPositionCenter, title: "INFO")
        
        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
//        types.removeObject(AVMetadataObjectTypeQRCode)
        self.output.metadataObjectTypes = NSArray(array: types) as [AnyObject]
        
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview as! UIView)
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
        let managedObjectContext = Singleton.sharedInstance.managedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "Configuration")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "main_config")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                var managedObject = fetchResults[0]
                managedObject.setValue(barcodeNumber, forKey: "app_identifier")
                managedObjectContext!.save(nil)
            }
        }
        
        let vc : MainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
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