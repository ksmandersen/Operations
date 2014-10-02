//
//  DataToStringOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class DataToStringOperation : Operation {
	typealias Input = NSData
	typealias Output = String
	
	var input : Promise<Input>? {
		didSet {
			if input != nil {
				dispatch_async(dispatch_get_global_queue(0, 0)) {
					self.start()
				}
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
			let str = NSString(data: data, encoding: NSUTF8StringEncoding)
			output.value = str
		} else {
			fatalError(":(")
		}
	}
}
