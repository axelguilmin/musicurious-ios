//
//  API.swift
//  musicurious-ios
//
//  Created by Axel Guilmin on 10/8/15.
//  Copyright © 2015 Axel Guilmin. All rights reserved.
//

import Foundation

class API {
	
	static let BASE_URL = "http://musicurious-api.axelguilmin.fr/"
	
	static func get(method:String, param:[String:AnyObject]? = nil, success:(Int, AnyObject?) -> () = {_,_ in}, failure:() -> () = {}) {
		request("GET", method: method, param: param, success: success, failure: failure)
	}
	
	static func post(method:String, param:[String:AnyObject]? = nil, success:(Int, AnyObject?) -> () = {_,_ in}, failure:() -> () = {}) {
		request("POST", method: method, param: param, success: success, failure: failure)
	}
	
	static func put(method:String, param:[String:AnyObject]? = nil, success:(Int, AnyObject?) -> () = {_,_ in}, failure:() -> () = {}) {
		request("PUT", method: method, param: param, success: success, failure: failure)
	}
	
	static func delete(method:String, param:[String:AnyObject]? = nil, success:(Int, AnyObject?) -> () = {_,_ in}, failure:() -> () = {}) {
		request("DELETE", method: method, param: param, success: success, failure: failure)
	}
	
	static func request(httpMethod:String, method:String, param:[String:AnyObject]?, success:(Int, AnyObject?) -> (), failure:() -> ()) {
		let urlString = API.BASE_URL + method

		let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
		request.HTTPMethod = httpMethod
		request.timeoutInterval = 2 //seconds
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		// Pass query parameters
		if param != nil {
			// TODO: Send params as a json
//			do {
//				request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(param!, options: NSJSONWritingOptions(rawValue:0))
//			} catch let parsingError as NSError {
//				print(parsingError.description)
//			}
			
			var bodyData = ""
			for(key,value) in param! {
				bodyData.appendContentsOf("\(key)=\(value)&")
			}
			request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
		}
		
		// Pass cookie
		var xsrfCookie: NSHTTPCookie? = nil
		let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
		for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
		}
		
		// Send request
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { data, response, error  in
			if error != nil { // Network error
				print("↓ \(error!.description)")
				failure()
				return
			}
			
			do {
				let statusCode:Int = (response as! NSHTTPURLResponse).statusCode
				print("↓ \(statusCode) \(response!.URL!.description)")

				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
				success(statusCode, json)
			} catch let parsingError as NSError {
				print(parsingError.description)
			}
		}
		
		print("↑ \(httpMethod) \(urlString)")
		task.resume()
	}
}