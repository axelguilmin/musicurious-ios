//
//  ViewController.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 7/28/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// MARK: - Lifecyle
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		observeNotification(selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification)
		observeNotification(selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		stopObservingNotification(UIKeyboardWillShowNotification)
		stopObservingNotification(UIKeyboardWillHideNotification)
	}
	
	deinit {
		stopObservingNotifications()
	}
	
	// MARK: - func
	
	func keyboardWillShow(notification: NSNotification) { }
	func keyboardWillHide(notification: NSNotification) { }
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}

