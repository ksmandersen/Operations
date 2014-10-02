//
//  NetworkOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class NetworkOperation : Operation {
	typealias Input = Void
	typealias Output = NSData
	
	var input : Promise<Input>?
	var output : Promise<Output> = Promise()
	
	var url : String
	
	init(input : Promise<Input>? = nil, url : String) {
		self.url = url
		self.input = input ?? Promise(value: Void())
		
		dispatch_async(dispatch_get_global_queue(0, 0)) {
			self.start()
		}
	}
	
	func start() {
		input!.getValue()
		
		let request = NSURLRequest(URL: NSURL(string: url))
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: requestCompleted)
	}
	
	func requestCompleted(response : NSURLResponse!, data : NSData!, error : NSError?) {
		if let error = error {
			output.error = error
		} else {
			output.value = data
		}
	}
}
