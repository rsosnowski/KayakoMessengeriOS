//
//  Array+FirstSecondThird.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 14/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension Array {
	var second: Element? {
		if self.count > 1 {
			return self[1]
		} else {
			return nil
		}
	}
	
	var third: Element? {
		if self.count > 2 {
			return self[2]
		} else {
			return nil
		}
	}
	
	var first3: [Element] {
		return [self.first, self.second, self.third].flatMap{$0}
	}
}
