//
//  CountryViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 9/22/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import CoreData

class CountryViewController : UIPageViewController, UIPageViewControllerDataSource {
	
	// MARK: - var
	
	var playlist:Playlist!
	var countryCode:String!
	
	private var songs:[Song] {
		get {
			if let fetchedObjects = self.fetchedResultsController.fetchedObjects {
				return fetchedObjects as! [Song]
			}
			else {
				return [Song]()
			}
		}
	}
	
	// MARK: - IBOutlet

	@IBOutlet weak var activityIndicator: BarActivityIndicatorItem!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource = self
		self.title = Song.countryWithCountryCode(countryCode)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		try! fetchedResultsController.performFetch()
		self.setViewControllers([viewControllerForSong(songs.first!)], direction: .Forward, animated: true, completion: nil)
		
		observeNotification(selector: "addSongBegin", name: Notification.Playlist.AddSong.begin)
		observeNotification(selector: "addSongDone", name: Notification.Playlist.AddSong.done)
		observeNotification(selector: "addSongError", name: Notification.Playlist.AddSong.error)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
				
		stopObservingNotifications()
	}
	
	// MARK: - func
	
	private func viewControllerForSong(song:Song) -> SongViewController {
		let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("SongViewController") as! SongViewController
		songVC.song = song
		return songVC
	}
	
	// MARK: - UIPageViewControllerDataSource
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		let currentVC = viewController as! SongViewController
		let index = songs.indexOf(currentVC.song)!
		let beforeIndex = index < 1 ? songs.count - 1 : index - 1
		return viewControllerForSong(songs[beforeIndex])
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let currentVC = viewController as! SongViewController
		let index = songs.indexOf(currentVC.song)!
		let nextIndex = index == songs.count - 1 ? 0 : index + 1
		return viewControllerForSong(songs[nextIndex])
	}
	
	func presentationCountForPageViewController(_: UIPageViewController) -> Int {
		return songs.count
	}
	
	func presentationIndexForPageViewController(_: UIPageViewController) -> Int {
		return 0
	}
	
	// MARK: - IBAction
	
	@IBAction func newSongAction() {
		let newSongVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewSongViewController") as! NewSongViewController
		newSongVC.countryCode = self.countryCode
		newSongVC.playlist = self.playlist
		self.presentViewController(newSongVC, animated: true, completion: nil)
	}
	
	// MARK: - Notification
	
	func addSongBegin() {
		dispatch_async(dispatch_get_main_queue()) {
			self.activityIndicator.startAnimating()
		}
	}
	
	func addSongDone() {
		dispatch_async(dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
		}
	}
	
	func addSongError() {
		dispatch_async(dispatch_get_main_queue()) {
			let alert = UIAlertController(title: "Error", message: "A connexion error happened while adding the song", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			self.activityIndicator.stopAnimating()
		}
	}
	
	// MARK: - Fetched Results Controller
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "Song")
		fetchRequest.predicate = NSPredicate(format: "playlist = %@ AND countryCode = %@", self.playlist, self.countryCode)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: sharedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		return fetchedResultsController
	}()
}