//
//  ResourceName.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public enum ResourceName: String {
	
	case user_minimal
	case case_status
	case read_marker
	case minimalSet
	case conversation
	case attachment
	
	static let all = "*"
	
	public static func minimal<T>(for type: T.Type) -> [ResourceName] {
		switch T.self {
		case is Array<Conversation>.Type:
			return [.user_minimal, .read_marker]
		case is Conversation.Type:
			return [.user_minimal, .read_marker]
		case is Array<Message>.Type:
			return [.user_minimal, .attachment]
		case is Message.Type:
			return [.user_minimal, .attachment]
		case is StarterData.Type:
			return [.user_minimal]
		case is Rating.Type:
			return []
		default:
			#if DEBUG
				fatalError("Minimal set not found for type \(T.self)")
			#else
				return []
			#endif
		}
	}
}
