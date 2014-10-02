//
//  Promise.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

class Promise<T> {
	// value and error should really be a generic result enum, but Swift doesn't support that yet >_<
	
	var value : T? {
		didSet {
			dispatch_async(dispatch_get_main_queue(), notifyWaiters)
		}
	}
	
	var error : NSError? {
		didSet {
			dispatch_async(dispatch_get_main_queue(), notifyWaiters)
		}
	}
	
	var queue : [(T?, NSError?) -> Void] = []
	
	init() {
		value = nil
	}
	
	init(value : T) {
		self.value = value
	}
	
	func getValue() -> (T?, NSError?) {
		if let value = value {
			return (value, error)
		} else {
			let semaphore = dispatch_semaphore_create(0)
			
			waitForValue { value in
				dispatch_semaphore_signal(semaphore)
				return Void()
			}
			
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
			
			return (value, error)
		}
	}
	
	func waitForValue(gotValue : (T?, NSError?) -> Void) {
		queue.append(gotValue)
	}
	
	func notifyWaiters() {
		for waiter in queue {
			waiter(value, error)
		}
	}
}
