//
//  MessageStatus.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 30/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

public enum MessageStatus {
	case yetToSend
	case sent
	case delivered
	case seen
	case bounced
	case sending
	case failed
	case custom(String)
	
	public var statusText: String {
		switch self {
		case .yetToSend:
			return "Not Sent Yet."
		case .sent:
			return "Sent"
		case .delivered:
			return "Delivered. Not seen yet"
		case .seen:
			return "Seen"
		case .bounced:
			return "Bounced"
		case .failed:
			return "Failed. Tap to Resend"
		case .sending:
			return "Sending…"
		case .custom(let customString):
			return customString
		}
	}
	
	init? (text: String) {
		switch text.lowercased() {
		case "sent":
			self = .sent
		case "delivered":
			self = .delivered
		case "seen":
			self = .seen
		case "bounced":
			self = .bounced
		case "failed":
			self = .failed
		default:
			self = .custom(text)
		}
	}
}
