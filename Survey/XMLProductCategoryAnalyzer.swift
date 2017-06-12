//
//  XMLProductCategoryAnalyzer.swift
//  Survey
//
//  Created by Charles Balachandran on 25/03/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import CoreData

class XMLProductCategoryAnalyzer: NSObject, NSXMLParserDelegate {
    
    private var categories:[String] = []
      private var currentElement = NSString()
    
    func beginParsingXML() -> [String] {
        let bundle = NSBundle.mainBundle()
        var path = bundle.pathForResource("categories_en", ofType: "xml")
        var pre: String = NSLocale.preferredLanguages()[0] as! String
        
        
        if pre == "it" {
            path = bundle.pathForResource("categories_it", ofType: "xml")
        }
        
        var urlToSend: NSURL = NSURL(fileURLWithPath: path!)!
        
        // Parse the XML
        var parser = NSXMLParser(contentsOfURL: urlToSend)!
        parser.delegate = self
        
        var success:Bool = parser.parse()
        
        if success {
            println("parse success")
        } else {
            println("parse failure")
        }
        return categories
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        currentElement = elementName;
        
        if(elementName as NSString).isEqualToString("categories") {
           categories = []
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if string!.contains("\n") {
            
        } else if (currentElement as NSString).isEqualToString("category") {
            categories.append(string!)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
       

    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}

