//
//  NSObject.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 11/13/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import CoreData

extension NSObject {
	
	// MARK: - Notification shorthand
	
	func postNotification(name:String, userInfo:[NSObject:AnyObject]? = nil) {
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: self, userInfo: userInfo)
	}
	
	static func postNotification(name:String) {
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
	}
	
	static func postNotification(name:String, userInfo:[NSObject:AnyObject]?) {
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: userInfo)
	}
	
	func observeNotification(selector sel:Selector, name:String, object:NSObject? = nil) {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: sel, name: name, object: object)
	}
	
	func stopObservingNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func stopObservingNotification(name:String, object:NSObject? = nil) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: object)

	}
}