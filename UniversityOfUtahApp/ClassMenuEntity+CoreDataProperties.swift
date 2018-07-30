//
//  ClassMenuEntity+CoreDataProperties.swift
//  UniversityOfUtahApp
//
//  Created by Mohammad Zulqurnain on 07/09/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

import Foundation
import CoreData

extension ClassMenuEntity {
    
    @NSManaged var location: String
    @NSManaged var group: String
    @NSManaged var dayofweek: String
    @NSManaged var starttime: String
    @NSManaged var descriptiondetail: NSArray

}
