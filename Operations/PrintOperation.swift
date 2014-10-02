//
//  PrintOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class PrintOperation : Operation {
	typealias Input = String
	typealias Output = Void
	
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
	
	func start() {
		let (data, error) = input!.getValue()
		
		if let error = error {
			println("Operation failure: \(error.localizedDescription)")
			output.error = error
		} else {
			println("\(data)")
			output.value = Void()
		}
	}
}
