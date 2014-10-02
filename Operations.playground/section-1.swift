// Playground - noun: a place where people can play

import Foundation

class Promise<T> {
	var value : T? {
		didSet {
			assert(oldValue == nil, "Reassigning value to a promise")
			
			dispatch_async(dispatch_get_main_queue()) {
				self.notifyWaiters()
			}
		}
	}
	
	var error : NSError? {
		didSet {
			dispatch_async(dispatch_get_main_queue()) {
				self.notifyWaiters()
			}
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

protocol Operation {
	typealias Input
	typealias Output
	
	var input : Promise<Input>? { get set }
	var output : Promise<Output> { get }
}

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

class CompositeOperation<T : Operation, U : Operation where T.Output == U.Input> : Operation {
	typealias Input = T.Input
	typealias Output = U.Output
	
	var input : Promise<Input>? = nil
	var output : Promise<Output>
	
	let inputOperation : T
	let outputOperation : U
	
	init(_ inputOperation : T, _ outputOperation : U) {
		self.inputOperation = inputOperation
		self.outputOperation = outputOperation
		
		self.input = inputOperation.input
		self.output = outputOperation.output
		
		var outOp = outputOperation
		outOp.input = inputOperation.output
	}
}

infix operator |> {
associativity left
}

func |><T : Operation, U : Operation where T.Output == U.Input>(lhs : T, rhs : U) -> CompositeOperation<T, U> {
	return CompositeOperation(lhs, rhs)
}
