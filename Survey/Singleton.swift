//
//  Singleton.swift
//  Survey
//
//  Created by Charles Balachandran on 25/03/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Singleton {
    
    var isHousholdProduct = false
    var isLaundryProduct = false
    var isPersonalCareProduct = false
    
    // Product XML questions
    var productQiestion = NSMutableArray()

    var colors: [UIColor] = [
        UIColor(red: 0.121569, green: 0.466667, blue: 0.705882, alpha: 1),
        UIColor(red: 0.737255, green: 0.741176, blue: 0.133333, alpha: 1),
        UIColor(red: 1, green: 0.498039, blue: 0.054902, alpha: 1),
        UIColor(red: 0.172549, green: 0.627451, blue: 0.172549, alpha: 1),
        UIColor(red: 0.839216, green: 0.152941, blue: 0.156863, alpha: 1),
        UIColor(red: 0.580392, green: 0.403922, blue: 0.741176, alpha: 1),
        UIColor(red: 0.54902, green: 0.337255, blue: 0.294118, alpha: 1),
        UIColor(red: 0.890196, green: 0.466667, blue: 0.760784, alpha: 1),
        UIColor(red: 0.498039, green: 0.498039, blue: 0.498039, alpha: 1),
        UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1)
    ]
    
    // Current question index of questions[] array
    var currentProductQNr = 0
    var currentPersoalQNr = 0
    
    // Done questions info
    var doneProductQuestions:[Int] = []
    var doneProductQuestionPosition = 0
    
    // If there is a loop, count number of loops
    var loopCounter = 0
    
    var currentProductsDetails:[NSMutableDictionary] = []

    // Contains product questions answers
    var answersProductQuestions = NSMutableDictionary()
    // Contains personal questions answers
    var answersPersonalQuetions = NSMutableDictionary()
    
    // managedObject to access database
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    class var sharedInstance: Singleton {
        struct Static {
            static var instance: Singleton?
        }
        
        if (Static.instance == nil) {
            Static.instance = Singleton()
        }
        
        return Static.instance!
    }
    
}