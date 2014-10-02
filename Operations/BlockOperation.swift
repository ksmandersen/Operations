//
//  BlockOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 02/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class BlockOperation<Input, Output> : Operation {
	var input : Promise<Input>? {
		didSet {
			if input != nil {
				dispatch_async(dispatch_get_global_queue(0, 0), start)
			}
		}
	}
	
	var output : Promise<Output> = Promise()
	
	var block : (Input?, NSError?) -> (Output?, NSError?)
	
	init(input : Promise<Input>? = nil, block : (Input?, NSError?) -> (Output?, NSError?)) {
		self.input = input
		self.block = block
	}
	
	func start() {
		let (data, error) = input!.getValue()
		(output.value, output.error) = block(data, error)
	}
}
