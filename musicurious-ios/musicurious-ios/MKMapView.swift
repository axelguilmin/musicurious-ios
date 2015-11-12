//
//  MKMapView.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 9/23/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

// source: https://github.com/johndpope/MKMapViewZoom
// Question : https://stackoverflow.com/questions/1636868/is-there-way-to-limit-mkmapview-maximum-zoom-level

import UIKit
import MapKit

let MERCATOR_OFFSET:Double = 268435456.0
let MERCATOR_RADIUS:Double = 85445659.44705395

extension MKMapView {
	
	// Mark: -
	// Mark: Map conversion methods
	
	class func longitudeToPixelSpaceX(longitude:Double) -> Double {
		return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0)
	}
	
	class func latitudeToPixelSpaceY(latitude:Double) -> Double {
		if (latitude == 90.0) {
			return 0
		} else if (latitude == -90.0) {
			return MERCATOR_OFFSET * 2.0
		} else {
			return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * M_PI / 180.0)) / (1 - sin(latitude * M_PI / 180.0))) / 2.0)
		}
	}
	
	class func pixelSpaceXToLongitude(pixelX:Double) -> Double {
		return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
	}
	
	class func pixelSpaceYToLatitude(pixelY:Double) -> Double {
		return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
	}
	
	// Mark -
	// Mark: Helper methods

	func coordinateSpanWithMapView(mapView:MKMapView, centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double) -> MKCoordinateSpan {
		
		// convert center coordiate to pixel space
		let centerPixelX = MKMapView.longitudeToPixelSpaceX(centerCoordinate.longitude)
		let centerPixelY = MKMapView.latitudeToPixelSpaceY(centerCoordinate.latitude)

		// determine the scale value from the zoom level
		let zoomExponent = 20 - zoomLevel
		let zoomScale = pow(2.0, zoomExponent)
		
		// scale the map’s size in pixel space
		let mapSizeInPixels = mapView.bounds.size
		let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
		let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
	
		// figure out the position of the top-left pixel
		let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
		let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
	
		// find delta between left and right longitudes
		let minLng = MKMapView.pixelSpaceXToLongitude(topLeftPixelX)
		let maxLng = MKMapView.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
		let longitudeDelta = maxLng - minLng
		
		// find delta between top and bottom latitudes
		let minLat = MKMapView.pixelSpaceYToLatitude(topLeftPixelY)
		let maxLat = MKMapView.pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight)
		let latitudeDelta = -1 * (maxLat - minLat)
	
		// create and return the lat/lng span
		let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
		return span
}

// Mark: -
// Mark: Public methods

	func setCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, var zoomLevel:Double, animated:Bool) {
		// clamp large numbers to 28
		zoomLevel = min(zoomLevel, 28.0)
		
		// use the zoom level to compute the region
		let span:MKCoordinateSpan = self.coordinateSpanWithMapView(self, centerCoordinate:centerCoordinate, zoomLevel:zoomLevel)
		let region = MKCoordinateRegion(center:centerCoordinate, span:span)
		
		// set the region like normal
		setRegion(region, animated:animated)
	}
	
//KMapView cannot display tiles that cross the pole (as these would involve wrapping the map from top to bottom, something that a Mercator projection just cannot do).
	func coordinateRegionWithMapView(mapView:MKMapView, var centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double) -> MKCoordinateRegion {
		// clamp lat/long values to appropriate ranges
		centerCoordinate.latitude = min(max(-90.0, centerCoordinate.latitude), 90.0)
		centerCoordinate.longitude = fmod(centerCoordinate.longitude, 180.0)
		
		// convert center coordiate to pixel space
		let centerPixelX = MKMapView.longitudeToPixelSpaceX(centerCoordinate.longitude)
		let centerPixelY = MKMapView.latitudeToPixelSpaceY(centerCoordinate.latitude)
	
		// determine the scale value from the zoom level
	let zoomExponent = 20 - zoomLevel // NSInteger
		let zoomScale = pow(2.0, zoomExponent) // double
		
		// scale the map’s size in pixel space
		let mapSizeInPixels = mapView.bounds.size
		let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
		let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
		
		// figure out the position of the left pixel
		let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
		
		// find delta between left and right longitudes
		let minLng = MKMapView.pixelSpaceXToLongitude(topLeftPixelX)
		let maxLng = MKMapView.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
		let longitudeDelta = maxLng - minLng
	
		// if we’re at a pole then calculate the distance from the pole towards the equator
		// as MKMapView doesn’t like drawing boxes over the poles
		var topPixelY = centerPixelY - (scaledMapHeight / 2)
		var bottomPixelY = centerPixelY + (scaledMapHeight / 2)
		var adjustedCenterPoint = false
		if topPixelY > MERCATOR_OFFSET * 2 {
			topPixelY = centerPixelY - scaledMapHeight
			bottomPixelY = MERCATOR_OFFSET * 2
			adjustedCenterPoint = true
		}
		
		// find delta between top and bottom latitudes
		let minLat = MKMapView.pixelSpaceYToLatitude(topPixelY)
		let maxLat = MKMapView.pixelSpaceYToLatitude(bottomPixelY)
		let latitudeDelta = -1 * (maxLat - minLat)
	
		// create and return the lat/lng span
		let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
		var region = MKCoordinateRegionMake(centerCoordinate, span)
		// once again, MKMapView doesn’t like drawing boxes over the poles
		// so adjust the center coordinate to the center of the resulting region
		if adjustedCenterPoint {
		region.center.latitude = MKMapView.pixelSpaceYToLatitude((bottomPixelY + topPixelY) / 2.0)
		}
		
		return region
	}
	
	func zoomLevel() -> Double {
		
		let centerPixelX = MKMapView.longitudeToPixelSpaceX(region.center.longitude)
		let topLeftPixelX = MKMapView.longitudeToPixelSpaceX(region.center.longitude - region.span.longitudeDelta / 2)
		
		let scaledMapWidth = (centerPixelX - topLeftPixelX) * 2
		let mapSizeInPixels = self.bounds.size
		let zoomScale = scaledMapWidth / Double(mapSizeInPixels.width)
		let zoomExponent = log(zoomScale) / log(2)
		let zoomLevel = 20.0 - zoomExponent
		
		return zoomLevel
}


}