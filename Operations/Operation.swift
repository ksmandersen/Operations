//
//  Operations.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import Foundation

protocol Operation {
	typealias Input
	typealias Output
	
	var input : Promise<Input>? { get set }
	var output : Promise<Output> { get }
}
