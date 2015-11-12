//
//  Song.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 9/21/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import Foundation
import CoreData

class Song: NSManagedObject {
	
	static func countryWithCountryCode(countryCode:String) -> String? {
		let locale = NSLocale.currentLocale()
		return locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)
	}
	
	lazy var country:String? = {
		return Song.countryWithCountryCode(self.countryCode)
	}()

	// MARK: Lifecycle
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("Song", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	convenience init(_ info:[String:AnyObject], context: NSManagedObjectContext) {
		self.init(context: context)
		
		if(info.indexForKey("artist") != nil) { artist = info["artist"] as? String }
		if(info.indexForKey("country") != nil) { countryCode = info["country"] as! String }
		if(info.indexForKey("title") != nil) { title = info["title"] as! String }
		if(info.indexForKey("year") != nil) { year = NSNumber(info["year"] as? String) }
		if(info.indexForKey("youtubeId") != nil) { youtubeId = info["youtubeId"] as! String }
		if(info.indexForKey("id") != nil) { id = NSNumber(info["id"] as? String)! }
	}
	
	func asDictionary() -> [String:AnyObject] {
		var dict:[String:AnyObject?] = ["artist":artist, "title":title, "year":year, "country":countryCode, "youtubeId":youtubeId, "id":id, "playlist":playlist.id];
		let keysToRemove = dict.keys.filter { dict[$0]! == nil }
		for key in keysToRemove { dict.removeValueForKey(key) }
		return dict as! [String:AnyObject]
	}
	
	var completeTitle:String {
		var completeTitle = title
		if artist != nil && artist != "" { completeTitle.appendContentsOf(" - \(artist!)") }
		if year != nil { completeTitle.appendContentsOf(" (\(year!))") }
		return completeTitle
	}
	
	/// Example of urls :
	///	https://www.youtube.com/watch?v=UzRtrjyDwx0
	///	https://youtu.be/6butf1tEVKs?t=22s
	///	https://youtu.be/R46-XgqXkzE?t=2m52s
	///	http://youtu.be/dQw4w9WgXcQ
	///	http://www.youtube.com/?v=dQw4w9WgXcQ
	///	http://www.youtube.com/?v=dQw4w9WgXcQ&feature=player_embedded
	/// http://www.youtube.com/watch?v=dQw4w9WgXcQ
	///	http://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=player_embedded
	///	http://www.youtube.com/v/dQw4w9WgXcQ
	///	http://www.youtube.com/e/dQw4w9WgXcQ
	///	http://www.youtube.com/embed/dQw4w9WgXcQ
	/// Returns dQw4w9WgXcQ
	static func youtubeIdWithURL(url:String) -> String? {
		let pattern = "\\W([\\w-]{11})(\\W|$)"
		// http://stackoverflow.com/a/8260383/1327557
		//let pattern = "^(?:https?:\\/\\/)?(?:www.)?(?:youtu\\.be\\/|youtube\\.com(?:\\/embed\\/|\\/v\\/|.*v=))([\\w-]{10,12})($|&).*$"
		
		if let match = url.rangeOfString(pattern, options: .RegularExpressionSearch) {
			var id = url.substringWithRange(match)
			if id[0] == "/" || id[0] == "=" {
				id = id.substringFromIndex(id.startIndex.advancedBy(1))
			}
			return id.truncate(11)
		}
		return nil
	}
	
}
