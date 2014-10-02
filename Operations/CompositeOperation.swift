//
//  CompositeOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

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
