//
//  ViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 7/28/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	// MARK: - var
	
	var notificationCenter:NSNotificationCenter {
		return NSNotificationCenter.defaultCenter()
	}
	
	// MARK: - Lifecyle
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	// MARK: - func
	
	func keyboardWillShow(notification: NSNotification) { }
	func keyboardWillHide(notification: NSNotification) { }
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}

