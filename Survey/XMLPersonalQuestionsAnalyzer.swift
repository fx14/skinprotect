//
//  XMLLexicalAnalyzer.swift
//  Survey
//
//  Created by Charles Balachandran on 24/03/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit
import CoreData

class XMLPersonalQuestionsAnalyzer: NSObject, NSXMLParserDelegate {
    
    // Contains all questions parsed from XML
    private var questions = NSMutableArray()
    
    private var currentElement = NSString()
    private var descSpecialChracterElement: String?
    private var choiceSpecialChracterElement = ""
    private var myList:[String] = []
    
    private var qid = ""
    private var questiondesc = ""
    private var typeid = ""
    private var min = ""
    private var max = ""
    private var gobackto = ""
    private var surveyTitle = ""
    private var choices:[String] = []
    private var imageURL = ""
    private var subtitle = ""
    
    private var parentQuestionID:[String] = []
    private var parentQuestionValueCondition:[String] = []
    
    func beginParsingXML(typeFile : String) -> NSMutableArray {
        questions = []
        var path = loadXMLURL(typeFile)
        
        if Reachability.isConnectedToNetwork() {
            // url path
            var urlToSend: NSURL = NSURL(string: path)!
            
            // Parse the XML
            var parser = NSXMLParser(contentsOfURL: urlToSend)!
            parser.delegate = self
            
            var success:Bool = parser.parse()
            
            if success {
                println("parse success")
            } else {
                println("parse failure")
            }
        } else {
            println("Parser was not able to connect to internet")
        }
        return questions
    }
    private func loadXMLURL(fileName: String) -> String {
        var path = ""
        var pre: String = NSLocale.preferredLanguages()[0] as! String
        if fileName == "personal" {
            if pre == "it" {
                path = "http://129.132.42.250/~students/xmlQuestions/personal_questions_it.xml"
            } else if pre == "de" {
                path = "http://129.132.42.250/~students/xmlQuestions/personal_questions_de.xml"
            } else if pre == "fr" {
                path = "http://129.132.42.250/~students/xmlQuestions/personal_questions_fr.xml"
            } else {
                path = "http://129.132.42.250/~students/xmlQuestions/personal_questions_en.xml"
            }
        } else if fileName == "product" {
            if pre == "it" {
                path = "http://129.132.42.250/~students/xmlQuestions/product_questions_it.xml"
            } else if pre == "de" {
                path = "http://129.132.42.250/~students/xmlQuestions/product_questions_de.xml"
            } else if pre == "fr" {
                path = "http://129.132.42.250/~students/xmlQuestions/product_questions_fr.xml"
            } else {
                path = "http://129.132.42.250/~students/xmlQuestions/product_questions_en.xml"
            }
        }
        return path
    }
    
    private func loadXMLPath(fileName :String) -> String {
        var path = ""
        let bundle = NSBundle.mainBundle()
        var pre: String = NSLocale.preferredLanguages()[0] as! String
        if fileName == "personal" {
            if pre == "it" {
                path = bundle.pathForResource("personal_questions_it", ofType: "xml")!
            } else if pre == "de" {
                path = bundle.pathForResource("personal_questions_de", ofType: "xml")!
            } else if pre == "fr" {
                path = bundle.pathForResource("personal_questions_fr", ofType: "xml")!
            } else {
                path = bundle.pathForResource("personal_questions_en", ofType: "xml")!
            }
        } else if fileName == "product" {
            if pre == "it" {
                path = bundle.pathForResource("product_questions_it", ofType: "xml")!
            } else if pre == "de" {
                path = bundle.pathForResource("product_questions_de", ofType: "xml")!
            } else if pre == "fr" {
                path = bundle.pathForResource("product_questions_fr", ofType: "xml")!
            } else {
                path = bundle.pathForResource("product_questions_en", ofType: "xml")!
            }
        }
        return path
    }
    
    //    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        currentElement = elementName;
        
        // Check if there is a special chracter in question description
        if (elementName as NSString).isEqualToString("questiondesc") {
            descSpecialChracterElement = ""
        } else {
            descSpecialChracterElement = nil
        }
        
        if (elementName as NSString).isEqualToString("choice") {
            choiceSpecialChracterElement = ""
        } else {
            choiceSpecialChracterElement = ""
        }
        
        if(elementName as NSString).isEqualToString("question") {
            qid = ""
            descSpecialChracterElement = ""
            questiondesc = ""
            typeid = ""
            choices = []
            min = ""
            max = ""
            gobackto = ""
            surveyTitle = ""
            imageURL = ""
            subtitle = ""
            parentQuestionID = []
            if let parentQuestion = attributeDict["parentquestionID"] as? String {
                parentQuestionID = parentQuestion.componentsSeparatedByString("|")
            }
            if let parentQuestionCondition = attributeDict["valuecondition"] as? String {
                parentQuestionValueCondition = parentQuestionCondition.componentsSeparatedByString("|")
            }
        } else if (elementName as NSString).isEqualToString("country") {
            var countryName = attributeDict["countryName"] as! String
            choices.append(countryName)
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if string!.contains("\n") {
            
        } else if (currentElement as NSString).isEqualToString("qid") {
            qid = string!
        } else if (currentElement as NSString).isEqualToString("questiondesc") {
            descSpecialChracterElement? += string!
            questiondesc = descSpecialChracterElement!
        } else if (currentElement as NSString).isEqualToString("typeid") {
            typeid = string!
        } else if (currentElement as NSString).isEqualToString("gobackto") {
            gobackto = string!
        } else if (currentElement as NSString).isEqualToString("choice") {
            choiceSpecialChracterElement += string!
            //            choices.append(choiceSpecialChracterElement!)
        } else if (currentElement as NSString).isEqualToString("min") {
            min = string!
        } else if (currentElement as NSString).isEqualToString("max") {
            max = string!
        } else if (currentElement as NSString).isEqualToString("surveyname") {
            surveyTitle = string!
        } else if (currentElement as NSString).isEqualToString("imageURL") {
            imageURL = string!
        } else if (currentElement as NSString).isEqualToString("subtitle") {
            subtitle = string!
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName as NSString).isEqualToString("choice") {
            //                println(choiceSpecialChracterElement)
            choices.append(choiceSpecialChracterElement)
        }
        choiceSpecialChracterElement = ""
        
        if (elementName as NSString).isEqualToString("question") {
            var question = NSMutableDictionary()
            
            if !qid.isEqual("") {
                question.setObject(qid, forKey: "qid")
            }
            if !questiondesc.isEqual("") {
                question.setObject(questiondesc, forKey: "questiondesc")
            }
            if !subtitle.isEqual("") {
                question.setObject(subtitle, forKey: "subtitle")
            }
            if !typeid.isEqual("") {
                question.setObject(typeid, forKey: "typeid")
            }
            if !choices.isEmpty {
                question.setObject(choices, forKey: "choices")
            }
            if !min.isEqual("") {
                question.setObject(min, forKey: "min")
            }
            if !max.isEqual("") {
                question.setObject(max, forKey: "max")
            }
            if !gobackto.isEqual("") {
                question.setObject(gobackto, forKey: "gobackto")
            }
            if !parentQuestionID.isEmpty {
                question.setObject(parentQuestionID, forKey: "parentquestionID")
            }
            if !parentQuestionValueCondition.isEmpty {
                question.setObject(parentQuestionValueCondition, forKey: "valuecondition")
            }
            if !imageURL.isEqual("") {
                question.setObject(imageURL, forKey: "imageURL")
            }
            questions.addObject(question)
            
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}