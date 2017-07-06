//
//  NSURLSession.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 14/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension URLRequest {
	var jsonPayload: Any {
		get {
			return httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0) } ?? [:]
		}
		set {
			httpBody = try? JSONSerialization.data(withJSONObject: newValue)
		}
	}
}
