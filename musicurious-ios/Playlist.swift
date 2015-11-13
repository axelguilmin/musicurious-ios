//
//  Playlist.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 9/21/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import CoreData

class Playlist: NSManagedObject {
	
	// MARK: Lifecycle
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	func updateWithInfo(info:[String:AnyObject], context: NSManagedObjectContext) {
		if(info.indexForKey("id") != nil) { id = NSNumber(info["id"] as? String)! }
		if(info.indexForKey("name") != nil) { name = info["name"] as? String }
		
		if(info.indexForKey("songs") != nil) {
			// Clear previous songs set
			for song in self.songs {
				sharedContext.deleteObject(song as! Song)
			}
			// Add updated songs set
			var songs = Set<Song>()
			for songInfo in info["songs"] as! [[String:AnyObject]] {
				let song = Song(songInfo, context:context)
				songs.insert(song)
			}
			self.songs = songs
		}
	}
	
	// MARK - METHOD
	
	func songsForCountryCode(countryCode:String?) -> [Song] {
		if countryCode == nil { return [Song]() }
		let fetchRequest = NSFetchRequest(entityName: "Song")
		fetchRequest.predicate = NSPredicate(format: "countryCode = %@ AND playlist == %@", countryCode!, self)
		return (try! sharedContext.executeFetchRequest(fetchRequest)) as! [Song]
	}
	
	// MARK - API
	
	static func loadPlaylistWithId(id:NSNumber) {
		API.get("playlist/\(id)", param:nil, success:{ HTTPCode, json in
			let fetchRequest = NSFetchRequest(entityName: "Playlist")
			fetchRequest.predicate = NSPredicate(format: "id = %@", id)
			let result = try! sharedContext.executeFetchRequest(fetchRequest) as! [Playlist]
			let playlist = result.count > 0 ? result.first! : Playlist(context: sharedContext)
			playlist.updateWithInfo(json as! [String:AnyObject] , context: sharedContext)
			CoreDataStackManager.sharedInstance().saveContext()
			playlist.postNotification(Notification.Playlist.LoadPlaylist.done)
			}, failure: {
				// Try again
				loadPlaylistWithId(id)
		})
		Playlist.postNotification(Notification.Playlist.LoadPlaylist.begin)
	}
	
	func addSong(song:Song) {
		API.post("song", param:song.asDictionary(),
			success: {HTTPCode, json in
				self.updateWithInfo(json as! [String:AnyObject] , context: sharedContext)
				CoreDataStackManager.sharedInstance().saveContext()
				self.postNotification(Notification.Playlist.AddSong.done)
			},
			failure: {
				self.postNotification(Notification.Playlist.AddSong.error)
		})
		self.postNotification(Notification.Playlist.AddSong.begin)
	}
}
