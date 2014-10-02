//
//  ImageResizeOperation.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import UIKit

class ImageResizeOperation : Operation {
	typealias Input = UIImage
	typealias Output = UIImage
	
	var input : Promise<Input>? {
		didSet {
			if input != nil {
				dispatch_async(dispatch_get_global_queue(0, 0), start)
			}
		}
	}
	
	var output : Promise<Output> = Promise()
	var newSize : CGSize
	
	init(input : Promise<Input>? = nil, toSize size : CGSize) {
		self.input = input
		self.newSize = size
	}
	
	func start() {
		let (image, error) = input!.getValue()
		
		if let error = error {
			output.error = error
		} else if let image = image {
			output.value = resizeImage(image, toSize: newSize)
		} else {
			fatalError(":(")
		}
	}
	
	func resizeImage(image : UIImage, toSize size : CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.mainScreen().scale)
		image.drawInRect(CGRect(origin: CGPointZero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
}
