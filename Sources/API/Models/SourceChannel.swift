//
//  SourceChannel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 10/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

public enum SourceChannel: String {
	case API
	case MESSENGER
	case HELPCENTER

	init?(text: String) {
		switch text.lowercased() {
		case "api":
			self = .API
		case "messenger":
			self = .MESSENGER
		case "helpcenter":
			self = .HELPCENTER
		default:
			return nil
		}
	}
}
