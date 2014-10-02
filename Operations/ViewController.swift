//
//  ViewController.swift
//  Operations
//
//  Created by Ulrik Damm on 01/10/14.
//  Copyright (c) 2014 Ulrik Damm. All rights reserved.
//

import UIKit

class ImageCollectionViewCell : UICollectionViewCell {
	@IBOutlet var imageView : UIImageView!
	@IBOutlet var spinner : UIActivityIndicatorView!
	@IBOutlet var errorLabel : UILabel!
}

enum DribbbleSection : String {
	case Everyone = "everyone"
	case Popular = "popular"
}

enum ImageResult {
	case Image(UIImage)
	case Error(NSError)
	case Loading
}

class ImageDataSource : NSObject, UICollectionViewDataSource {
	var images : [ImageResult] = []
	var collectionView : UICollectionView?
	
	func setupForCollectionView(collectionView : UICollectionView) {
		collectionView.dataSource = self
		self.collectionView = collectionView
	}
	
	func loadStuff(from : DribbbleSection) {
		resetContent()
		
		let url = "http://api.dribbble.com/shots/\(from.toRaw())"
		
		let op = NetworkOperation(url: url) |> JsonOperation()
		
		op.output.waitForValue { json, error in
			if let error = error {
				println("Error: \(error.localizedDescription)") // Such error handling ಠ_ಠ
			} else if let json = json {
				let shots = json["shots"].arrayValue!
				
				self.loadImages(shots.map() { shot in shot["image_url"].stringValue! })
			}
		}
	}
	
	func loadImages(urls : [String]) {
		self.images = Array(count: urls.count, repeatedValue: .Loading)
		self.collectionView?.reloadData()
		
		for (index, imageUrl) in enumerate(urls) {
			// TODO: cancel these requests when section tab is switched.
			// Also, support cancellation in operations
			
			let op = NetworkOperation(url: imageUrl) |> DataToImageOperation() |> ImageResizeOperation(toSize: CGSize(width: 160, height: 120))
			
			op.output.waitForValue { (image, error) in
				if let image = image {
					self.images[index] = .Image(image)
				} else if let error = error {
					self.images[index] = .Error(error)
				}
				
				self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
			}
		}
	}
	
	func resetContent() {
		images = []
		collectionView?.reloadData()
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as ImageCollectionViewCell
		
		let imageResult = images[indexPath.row]
		
		switch imageResult {
		case .Loading:
			cell.imageView.image = nil
			cell.spinner.startAnimating()
			cell.errorLabel.text = ""
		case .Image(let image):
			cell.imageView.image = image
			cell.spinner.stopAnimating()
			cell.errorLabel.text = ""
		case .Error(let error):
			cell.imageView.image = nil
			cell.spinner.stopAnimating()
			cell.errorLabel.text = error.localizedDescription
		}
		
		return cell
	}
}

class ViewController: UIViewController {
	@IBOutlet var collectionView : UICollectionView!
	var dataSource = ImageDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource.setupForCollectionView(collectionView)
		dataSource.loadStuff(.Everyone)
	}
	
	@IBAction func sectionSwitched(sender: UISegmentedControl) {
		dataSource.loadStuff(sender.selectedSegmentIndex == 0 ? .Everyone : .Popular)
	}
}

