//
//  CoreDataStack.swift
//  WorldCup
//
//  Created by Pietro Rea on 8/2/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import CoreData

class CoreDataStack {
  
  let modelName = "UniversityOfUtahApp"
  
  lazy var context: NSManagedObjectContext = {
    
    var managedObjectContext = NSManagedObjectContext(
      concurrencyType: .mainQueueConcurrencyType)
    
    managedObjectContext.persistentStoreCoordinator = self.psc
    return managedObjectContext
    }()
  
  fileprivate lazy var psc: NSPersistentStoreCoordinator = {
    
    let coordinator = NSPersistentStoreCoordinator(
      managedObjectModel: self.managedObjectModel)
    
    let url = self.applicationDocumentsDirectory
      .appendingPathComponent(self.modelName)
    
    do {
      let options =
      [NSMigratePersistentStoresAutomaticallyOption : true]
      
      try coordinator.addPersistentStore(
        ofType: NSSQLiteStoreType, configurationName: nil, at: url,
        options: options)
    } catch  {
      print("Error adding persistent store.")
    }
    
    return coordinator
    }()
  
  fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
    
    let modelURL = Bundle.main
      .url(forResource: self.modelName,
        withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
    }()
  
  fileprivate lazy var applicationDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(
      for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
    }()
  
  func saveContext () {
    if context.hasChanges {
      do {
        try context.save()
      } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
        abort()
      }
    }
  }
}
