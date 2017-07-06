//
//  URL+Unboxable.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox
import Foundation

extension URL: UnboxableRawType {
	
	public static func transform(unboxedNumber: NSNumber) -> URL? {
		return nil
	}
	
	public static func transform(unboxedString: String) -> URL? {
		return URL(string: unboxedString)
	}
}
