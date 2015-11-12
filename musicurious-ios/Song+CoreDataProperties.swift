//
//  Song+CoreDataProperties.swift
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

extension Song {

    @NSManaged var artist: String?
    @NSManaged var countryCode: String
    @NSManaged var title: String
    @NSManaged var wikipediaLocalization: String?
    @NSManaged var wikipediaPage: String?
    @NSManaged var year: NSNumber?
    @NSManaged var youtubeId: String
    @NSManaged var id: NSNumber
    @NSManaged var playlist: Playlist

}
