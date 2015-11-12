//
//  NewSongViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 10/2/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import UIKit

class NewSongViewController : ViewController, UITextFieldDelegate {
	
	// MARK: - var
	
	var countryCode:String!
	var playlist:Playlist!
	
	// MARK: - IBOutlet
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var songTitle: UITextField!
	@IBOutlet weak var artist: UITextField!
	@IBOutlet weak var year: UITextField!
	@IBOutlet weak var youtubeLink: UITextField!
	@IBOutlet weak var playerView: YouTubePlayerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
		
		playerView.playerVars = [
			"cc_load_policy": 0,
			"iv_load_policy": 3,
			"modestbranding": 1,
			"rel": 0,
			"showinfo": 0,
			"autohide": 0,
			"autoplay": 1
		]
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if let country = Song.countryWithCountryCode(countryCode) {
			titleLabel.text = "Add a song from \(country)"
		}
	}
	
	// MARK: - IBAction
	
	@IBAction func cancel() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func done() {
		var info = ["country":countryCode]
		
		// title
		if songTitle.text != "" {
			info["title"] = songTitle.text
		}
		else {
			let alert = UIAlertController(title: "", message: "Title is required", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return;
		}
		
		// artist is optional
		if artist.text != "" {
			info["artist"] = artist.text
		}
		
		// year is optional
		if year.text != "" {
			let yearNumber = NSNumber(year.text)?.integerValue
			let calendar = NSCalendar.currentCalendar()
			let components = calendar.components(.Year, fromDate: NSDate())
			let currentYear = components.year
			if yearNumber == nil || yearNumber > currentYear || yearNumber < 1 {
				let alert = UIAlertController(title: "", message: "Year is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
				return
			}
			info["year"] = year.text
		}
		
		// youtubeID
		if let youtubeId = Song.youtubeIdWithURL(youtubeLink.text!) {
			info["youtubeId"] = youtubeId
		}
		else {
			let alert = UIAlertController(title: "", message: "Youtube link is required", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return;
		}
		
		// Add the song in the playlist
		let newSong = Song(info, context: sharedContext)
		newSong.playlist = playlist
		playlist.addSong(newSong)
	
		// Close
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: - Keyboard
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		// Go to the next field
		switch textField {
		case songTitle:
			artist.becomeFirstResponder()
		case artist:
			year.becomeFirstResponder()
		case year:
			youtubeLink.becomeFirstResponder()
		case youtubeLink:
			youtubeLink.resignFirstResponder()
			done()
		default:
			print("NewSongViewController textFieldShouldReturn unknown textfield")
		}
		
		return true
	}
	
	override func keyboardWillHide(notification: NSNotification) {
		// Load the video
		if let youtubeId = Song.youtubeIdWithURL(youtubeLink.text!) {
			print(youtubeId)
			playerView.loadVideoID(youtubeId)
		}
	}
}
