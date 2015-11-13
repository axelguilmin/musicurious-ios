//
//  Constants.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 11/13/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import Foundation

/// All notifications used in the app, by model
struct Notification {
	struct Playlist {
		struct LoadPlaylist {
			static let begin = "LoadPlaylistBegin"
			static let done = "LoadPlaylistDone"
			static let error = "LoadPlaylistError"
		}
		struct AddSong {
			static let begin = "AddSongBegin"
			static let done = "AddSongDone"
			static let error = "AddSongError"
		}
	}
	struct Song {
		// None yet
	}
}