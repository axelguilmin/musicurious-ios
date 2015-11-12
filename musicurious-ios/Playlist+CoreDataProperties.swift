//
//  Playlist+CoreDataProperties.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 10/25/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Playlist {

    @NSManaged var name: String?
    @NSManaged var id: NSNumber
    @NSManaged var songs: NSSet

}
