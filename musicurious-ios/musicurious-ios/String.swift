//
//  String.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 11/11/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import Foundation

extension String {
	
	subscript (i: Int) -> Character {
		return self[self.startIndex.advancedBy(i)]
	}
	
	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}
	
	subscript (r: Range<Int>) -> String {
		return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
	}
	
	/// Truncates the string to length number of characters and
	/// appends optional trailing string if longer
	func truncate(length: Int, trailing: String? = nil) -> String {
		if characters.count > length {
			return self.substringToIndex(startIndex.advancedBy(length)) + (trailing ?? "")
		} else {
			return self
		}
	}
}