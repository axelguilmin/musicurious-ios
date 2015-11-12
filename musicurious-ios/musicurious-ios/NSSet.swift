//
//  NSSet.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 10/26/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import Foundation

extension NSSet {
	func randomObject() -> AnyObject? {
		let count = allObjects.count
		return count > 0 ? allObjects[Int(arc4random()) % count] : nil
	}
}