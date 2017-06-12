//
//  Configuration.swift
//  Survey
//
//  Created by Charles Balachandran on 16/05/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation
import CoreData

class Configuration: NSManagedObject {

    @NSManaged var app_found_from: String
    @NSManaged var app_identifier: String
    @NSManaged var app_question: String
    @NSManaged var id: String
    @NSManaged var personal_question: String
    @NSManaged var product_question: String
    @NSManaged var terms_accepted: String

}
