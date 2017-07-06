//
//  Unbox+ISO8601.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 21/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox
import Foundation

public func iso8601Date(unboxer: Unboxer, key: String) throws -> Date {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale(identifier: "en_US_POSIX")
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
	return try unboxer.unbox(key: key, formatter: dateFormatter) as Date
}

