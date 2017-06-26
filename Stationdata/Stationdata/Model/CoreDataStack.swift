//
//  CoreDataStack.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    static let context: NSManagedObjectContext = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let url = directory.appendingPathComponent("database.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {}
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    private static let managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Stationdata", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
}
