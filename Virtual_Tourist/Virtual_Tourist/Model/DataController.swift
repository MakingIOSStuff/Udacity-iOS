//
//  DataController.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
            return persistentContainer.viewContext
        }
    let backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
//                return
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

//MARK: Auto Save Functionality

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("Auto Saving")
        
        guard interval > 0 else {
            print("Cannot save at negative time intervals")
            return
        }
        //Check for changes before saving
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        //Begin auto saving
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}


