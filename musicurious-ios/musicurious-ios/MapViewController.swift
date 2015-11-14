//
//  MapViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 7/28/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - Const
private let USER_DEFAULT_MAP_POSITION_KEY = "MapRegion"

// TODO: Allow zoom, but limited zoom level
class MapViewController : ViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

	// MARK: - var
	
	private var countryCode:String!
	
	// Unique playlist at first
	// TODO: support multiple playlists
	let playlistId:NSNumber = 1
	
	private var playlist:Playlist? {
		get {
			let playlists = self.fetchedResultsController.fetchedObjects
			return (playlists?.count)! == 0 ? nil : playlists![0] as? Playlist
		}
	}
	
	// MARK: - Outlet
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicator: BarActivityIndicatorItem!
	@IBOutlet weak var randomButton: UIBarButtonItem!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		// Disable the button until the playlist is loaded
		randomButton.enabled = false
		
		// Reload map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		if let regionDict = userDefault.objectForKey(USER_DEFAULT_MAP_POSITION_KEY) as? [String:CLLocationDegrees] {
			let region = MKCoordinateRegion(dictionary:regionDict)
			mapView.setRegion(region, animated: false)
		}
		mapView.showsPointsOfInterest = false
		mapView.showsTraffic = false
		mapView.setCenterCoordinate(mapView.centerCoordinate, zoomLevel: 3, animated: false)
		
		// Detect taps
		let addTapGestureRecognzier = UITapGestureRecognizer(target: self, action: "handleTap:")
		mapView.addGestureRecognizer(addTapGestureRecognzier);
		
		// Load the playlist from server
		self.observeNotification(selector: "loadPlaylistBegin", name: Notification.Playlist.LoadPlaylist.begin)
		self.observeNotification(selector: "loadPlaylistDone", name: Notification.Playlist.LoadPlaylist.done)
		Playlist.loadPlaylistWithId(1)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchedResultsController.delegate = self
		try! fetchedResultsController.performFetch()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		fetchedResultsController.delegate = nil
	}
	
	// MARK: - Notification
	
	func loadPlaylistBegin() {
		dispatch_async(dispatch_get_main_queue()) {
			self.activityIndicator.startAnimating()
		}
	}
	
	func loadPlaylistDone() {
		dispatch_async(dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
		}
	}
	
	// MARK: - func
	
	func handleTap(gestureRecognizer:UIGestureRecognizer) {
		let touchPoint = gestureRecognizer.locationInView(mapView)
		let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
		let location = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
		
		let geocoder = CLGeocoder()
		activityIndicator.startAnimating()
		geocoder.reverseGeocodeLocation(location) { place, error in
			self.activityIndicator.stopAnimating()

			if error != nil {
				var message = error?.description
				switch (CLError(rawValue:error!.code)!) {
				case .LocationUnknown:
					message = "This country is unknown"
					break
				case .Denied:
					message = "An error occured, please try again"
					break
				case .Network:
					message = "No internet connexion"
					break
				default:
					// Display the error description as a message
					break
				}
				
				let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
				return
			}
			
			if let countryCode = place!.first!.ISOcountryCode {
				self.countryCode = countryCode
			}
			else { return }
			
			if let playlist = self.playlist {
				if playlist.songsForCountryCode(self.countryCode).count > 0 {
					self.performSegueWithIdentifier("showSong", sender: self)
				}
				else {
					let newSongVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewSongViewController") as! NewSongViewController
					newSongVC.countryCode = self.countryCode
					newSongVC.playlist = self.playlist
					self.presentViewController(newSongVC, animated: true, completion: nil)
				}
			}
		}
	}
	
	// MARK: - MKMapViewDelegate
	
	func mapViewWillStartLoadingMap(mapView: MKMapView) {
		
		// Save map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		let regionDict = mapView.region.asDictionary()
		userDefault.setObject(regionDict, forKey: USER_DEFAULT_MAP_POSITION_KEY)
	}
	
	// MARK: - Segue
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let countryVC = segue.destinationViewController as? CountryViewController {
			countryVC.countryCode = countryCode
			countryVC.playlist = playlist
		}
	}
	
	// MARK: - Fetched Results Controller
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "Playlist")
		fetchRequest.predicate = NSPredicate(format: "id = %@", self.playlistId)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
		fetchRequest.fetchLimit = 1
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: sharedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		return fetchedResultsController
		
		}()
	
	
	// MARK: - Fetched Results Controller Delegate
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		title = playlist!.name
		randomButton.enabled = true
	}
	
	// MARK: - IBAction
	
	@IBAction func randomCountry(sender: AnyObject) {
		let song = playlist!.songs.randomObject() as! Song
		countryCode = song.countryCode
		performSegueWithIdentifier("showSong", sender: self)
	}
}