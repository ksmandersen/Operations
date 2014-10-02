//
//  JsonOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 02/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class JsonOperation : Operation {
	typealias Input = NSData
	typealias Output = JSON
	
	var input : Promise<Input>? {
		didSet {
			if input != nil {
				dispatch_async(dispatch_get_global_queue(0, 0), start)
			}
		}
	}
	
	var output : Promise<Output> = Promise()
	
	init(input : Promise<Input>? = nil) {
		self.input = input
	}
	
	func start() {
		let (data, error) = input!.getValue()
		
		if let error = error {
			output.error = error
		} else if let data = data {
			parseJson(data)
		} else {
			fatalError(":(")
		}
	}
	
	func parseJson(data : NSData) {
		var error : NSError?
		let json = JSON(data: data, options: nil, error: &error)
		
		if let error = error {
			output.error = error
		} else {
			output.value = json
		}
	}
}
