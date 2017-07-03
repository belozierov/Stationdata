//
//  CoreDataStack.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

final class CoreDataStack {
    
    private static let stack = CoreDataStack()
    
    static let viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = stack.coordinator
        NotificationCenter.default.addObserver(stack, selector: #selector(parseContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: parseContext)
        return context
    }()
    
    static let parseContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.persistentStoreCoordinator = stack.coordinator
        return context
    }()
    
    // MARK: Stack
    
    private lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let url = directory.appendingPathComponent("database.sqlite")
        do { try self.addPersistentStore(to: coordinator, at: url) } catch {
            do {
                try FileManager.default.removeItem(at: url)
                try self.addPersistentStore(to: coordinator, at: url)
            } catch {}
        }
        return coordinator
    }()
    
    private let managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Stationdata", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private func addPersistentStore(to coordinator: NSPersistentStoreCoordinator, at url: URL) throws {
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
    }
    
    // MARK: ParseContext observer
    
    @objc func parseContextDidSave(_ notification: Notification) {
        CoreDataStack.viewContext.perform {
            CoreDataStack.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}
