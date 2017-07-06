//
//  Dictionary+formURLEncoded.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 02/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension Dictionary where Key: ExpressibleByStringLiteral {
	
	/**
	Returns the parameters in using URL-enconding, for example ["username": "Michael", "age": 20] will become "username=Michael&age=20".
	*/
	public func urlEncodedString() throws -> String {
		
		let pairs = try self.reduce([]) { current, kvPair -> [String] in
			if let encodedValue = "\(kvPair.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
				return current + ["\(kvPair.key)=\(encodedValue)"]
			} else {
				throw NSError(domain: "com.kayako.customersuccess", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't encode \(kvPair.value)"])
			}
		}
		
		let converted = pairs.joined(separator: "&")
		
		return converted
	}
}
