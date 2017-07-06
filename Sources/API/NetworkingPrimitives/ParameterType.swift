//
//  ParameterType.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 02/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

public enum ParameterType {
	case none
	case json
	case formURLEncoded
	case multipartFormData
	case custom(String)
	
	func contentType(_ boundary: String) -> String? {
		switch self {
		case .none:
			return nil
		case .json:
			return "application/json"
		case .formURLEncoded:
			return "application/x-www-form-urlencoded"
		case .multipartFormData:
			return "multipart/form-data; boundary=\(boundary)"
		case .custom(let value):
			return value
		}
	}
}
