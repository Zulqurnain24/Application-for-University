//
//  ClassMenuEntity+CoreDataProperties.swift
//  UniversityOfUtahApp
//
//  Created by Mohammad Zulqurnain on 07/09/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

import Foundation
import CoreData

extension ReportEntity {
    
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var parentname: String
    @NSManaged var phonenumber: String
    @NSManaged var mobilenumber: String
    @NSManaged var emailaddress: String
}
