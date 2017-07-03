//
//  NSManagedObjectContext.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    func saveToPersistentStore() {
        var tempContext: NSManagedObjectContext? = self
        while let context = tempContext, context.hasChanges {
            do { try context.save() } catch {}
            tempContext = context.parent
        }
    }
    
}
