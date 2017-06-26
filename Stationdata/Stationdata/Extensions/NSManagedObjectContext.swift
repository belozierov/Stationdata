//
//  NSManagedObjectContext.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    func saveToPersistentStore(async: Bool = false) {
        var context: NSManagedObjectContext? = self
        func save() {
            while context != nil {
                guard context?.hasChanges == true else { return }
                do { try context?.save() } catch {}
                context = context?.parent
            }
        }
        if async {
            context?.perform { save() }
        } else {
            context?.performAndWait { save() }
        }
    }
    
}
