//
//  UIImage+Color.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 10/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

extension UIImage {
	static func fromColor(color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return UIImage()
		}
		
		context.setFillColor(color.cgColor)
		context.fill(rect)
		
		guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
			return UIImage()
		}
		
		UIGraphicsEndImageContext()
		return img
	}
}
