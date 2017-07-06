//
//  Array+RandomElement.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 06/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension Array {
	func random() -> Element? {
		if self.isEmpty { return nil }
		let randomInt = Int(arc4random_uniform(UInt32(self.count)))
		return self[randomInt]
	}
}
