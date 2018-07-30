//
//  Commit+CoreDataProperties.swift
//  Project38
//
//  Created by Hudzilla on 27/01/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RosterEntity {

    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var parentname: String
    @NSManaged var phonenumber: String
    @NSManaged var cellnumber: String
    @NSManaged var email: String
}
