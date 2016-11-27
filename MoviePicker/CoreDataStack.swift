//
//  CoreDataStack.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // MARK:  - Properties
    fileprivate let model : NSManagedObjectModel
    fileprivate let coordinator : NSPersistentStoreCoordinator
    fileprivate let modelURL : URL
    fileprivate let dbURL : URL
    let context : NSManagedObjectContext
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create a context and add connect it to the coordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let  docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
            
        }catch{
            print("unable to add store at \(dbURL)")
        }
        
        
        
        
        
    }
    
    // MARK:  - Utils
    func addStoreCoordinator(_ storeType: String,
                             configuration: String?,
                             storeURL: URL,
                             options : [AnyHashable: Any]?) throws{
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
        
    }
    
}

// MARK:  - Removing data
extension CoreDataStack  {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        
        
    }
}

// MARK:  - Save
extension CoreDataStack {
    
    func saveContext() throws{
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        if delayInSeconds > 0 {
            // Save the context
            do {
                try saveContext()
                print("autosaving")
            } catch {
                print("error while autosaving")
            }
            
            UserDefaults.standard.synchronize()
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.autoSave(delayInSeconds)
            })
        }
    }
}
