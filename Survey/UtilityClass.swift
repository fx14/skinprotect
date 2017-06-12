//
//  UtilityClass.swift
//  Survey
//
//  Created by Charles Balachandran on 27/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation
import UIKit

class UtilityClass {
    
    // convert hexadecimal color to UIColor with RGB
    class func uiColorFromHex (rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
        
        //        return false
    }
    
    class func imageResize (imageObj:UIImage, sizeChange:CGSize) -> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    class func loadImage (imageLink: String, imageView: UIImageView) {
        var imgURL: NSURL = NSURL(string: imageLink)!
        
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    imageView.image = image
                })
            } else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
    }
}