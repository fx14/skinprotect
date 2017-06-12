//
//  PersonalQuestion.swift
//  Survey
//
//  Created by Charles Balachandran on 13/05/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import Foundation
import CoreData

class PersonalQuestion: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var contact: String
    @NSManaged var doctor_contact: String
    @NSManaged var body_part: String
    @NSManaged var skin_allergy: String
    @NSManaged var education: String
    @NSManaged var zip: String
    @NSManaged var nationality: String
    @NSManaged var weight: String
    @NSManaged var height: String
    @NSManaged var age: String
    @NSManaged var gender: String

}
