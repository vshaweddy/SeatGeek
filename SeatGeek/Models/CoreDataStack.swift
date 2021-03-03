//
//  CoreDataStack.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import Foundation
import CoreData

final class CoreDataStack {
    private lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "SeatGeek")
        newContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Failed to load to persistent stores: \(error!)")
            }
        }
        newContainer.viewContext.automaticallyMergesChangesFromParent = true
        return newContainer
    }()
    
    /// Shared instance
    static let shared = CoreDataStack()
    
    /// Main view context
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    
    /// Saves the current context
    ///
    /// - Parameter context: The managed object context
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving contenxt: \(error)")
                // reset it in case it doesn't save but rarely happens
                context.reset()
            }
        }
    }
}
