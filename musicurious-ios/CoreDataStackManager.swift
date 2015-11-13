//
//  CoreDataStackManager.swift
//
//  Created by Jason on 3/10/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "Musicurious.sqlite"
private let MOMD_FILE_NAME = "Musicurious"

let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!

class CoreDataStackManager {
	
    // MARK: - Singleton
	
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
    
        return Static.instance
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
		
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
		
        let modelURL = NSBundle.mainBundle().URLForResource(MOMD_FILE_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
	
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
		
		do {
			try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch let error as NSError {
			// Left in for development.
			print(error.localizedDescription)
			abort()
		}
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        print("[CoreDataStackManager] create managedObjectContext")

        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data support
    
    func saveContext () {
		
		print("[CoreDataStackManager] saveContext")
		if let context = self.managedObjectContext {
			
			dispatch_async(dispatch_get_main_queue()) {
				if !context.hasChanges {
					return
				}
				
				do {
					try context.save()
				} catch let error as NSError {
					print(error.localizedDescription)
					abort()
				}
			}
		}
	}
	
	func delete(object:NSManagedObject) {
		dispatch_async(dispatch_get_main_queue()) {
			sharedContext.deleteObject(object)
		}
	}
}