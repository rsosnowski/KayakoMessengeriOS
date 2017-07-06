//
//  ResponseType.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 02/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//


enum ResponseType {
	case json
	case data
	case image
	
	var accept: String? {
		switch self {
		case .json:
			return "application/json"
		default:
			return nil
		}
	}
}
