//
//  SongViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 9/21/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import CoreData

class SongViewController : ViewController, YouTubePlayerDelegate {
	
	// MARK: - var
	
	var song:Song!
	
	// MARK: - Outlet
	
	@IBOutlet weak var playerView: YouTubePlayerView!
	@IBOutlet weak var titleLabel: UILabel!
	
	// MARK: - Lifecyle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		assert(nil != song)
		
		titleLabel.text = song.completeTitle
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		assert(nil != song)
		
		if(playerView.playerState == .Unstarted) {
			// See https://developers.google.com/youtube/player_parameters
			playerView.playerVars = [
				"cc_load_policy": 0,
				"iv_load_policy": 3,
				"modestbranding": 1,
				"rel": 0,
				"showinfo": 0,
				"autohide": 0,
			]
			playerView.loadVideoID(song.youtubeId)
			playerView.delegate = self;
		}
		
		if(playerView.playerState == .Paused) {
			playerView.play()
		}
	}
	
	// MARK: - YouTubePlayerDelegate
	
	func playerReady(videoPlayer: YouTubePlayerView) {
		videoPlayer.play()
	}
	
	func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
		
	}
	
	func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
		
	}
}