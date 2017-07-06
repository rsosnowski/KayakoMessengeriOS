//
//  StatusCodeType.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 02/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public enum StatusCodeType {
	case informational,
	successful,
	redirection,
	clientError,
	serverError,
	cancelled,
	unknown
}

public extension Int {
	
	/**
	Categorizes a status code.
	- returns: The NetworkingStatusCodeType of the status code.
	*/
	public func statusCodeType() -> StatusCodeType {
		switch self {
		case URLError.cancelled.rawValue:
			return .cancelled
		case 100 ..< 200:
			return .informational
		case 200 ..< 300:
			return .successful
		case 300 ..< 400:
			return .redirection
		case 400 ..< 500:
			return .clientError
		case 500 ..< 600:
			return .serverError
		default:
			return .unknown
		}
	}
}
