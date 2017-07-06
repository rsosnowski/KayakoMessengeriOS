//
//  UIView+Snapshot.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 06/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

public extension UIView {
	public func getSnapshotImage() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
		self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
		let snapshotImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return snapshotImage
	}
}
