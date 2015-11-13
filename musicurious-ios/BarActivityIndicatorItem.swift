//
//  BarActivityIndicatorItem.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 11/13/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import UIKit

/// a UIBarButtonItem that displays an Activity Indicator
class BarActivityIndicatorItem : UIBarButtonItem {
	
	// MARK: - Lifecycle
	
	override init() {
		super.init()
		customView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
	}
	
	// MARK: - func
	
	func startAnimating() {
		(customView as! UIActivityIndicatorView).startAnimating()
	}
	
	func stopAnimating() {
		(customView as! UIActivityIndicatorView).stopAnimating()
	}
}
