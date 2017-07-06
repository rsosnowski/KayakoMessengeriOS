//
//  NetworkResource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public enum MultiResource<T>: Pathable {
	//: eventually support other forms of pagination like cursors
	case paginated(parents: [(parentName: String, suffix: String?)]?, offset: Int?, limit: Int?)
	
	func path() -> (path: String, params: [String: String]) {
		switch self {
		case .paginated(let parents, let offset, _):
			let params: [String: String] = {
				var dict: [String: String] = [:]
				offset.flatMap{ dict["offset"] = "\($0)"}
//				limit.flatMap{ dict["limit"] = "\($0)" }
				dict["limit"] = "100"
				return dict
			}()
			let parents = parents?.flatMap{ $0 }.reduce("", { (result, parent) -> String in
				return result + [parent.parentName, parent.suffix].flatMap{ $0 }.joined(separator: "/") + "/"
			}) ?? ""
			switch T.self {
			case is Array<Conversation>.Type:
				return (parents + "conversations", params)
			case is Array<UserMinimal>.Type:
				return (parents + "users", params)
			case is Array<Message>.Type:
				return (parents + "messages", params)
			default:
				#if DEBUG
					fatalError("type not implemented: \(T.self)")
				#else
					return ("", [:])
				#endif
			}
		}
	}
}

extension MultiResource: Equatable {
	public static func ==(lhs: MultiResource, rhs: MultiResource) -> Bool {
		#if DEBUG
			fatalError("Comparing 2 paginated network resources doesn't really make sense")
		#else
			return false
		#endif
	}
}

public enum NetworkResource<T>: Pathable {
	case url(URL)
	case id(parents: [(parentName: String, suffix: String?)]?, id: Int)
	case standalone
	
	func path() -> (path: String, params: [String: String]) {
		switch self {
		case .url(url: _):
			return ("",[:])

		case .id(let parents, let id):
			let params: [String: String] = [:]
			let parents = parents?.flatMap{ $0 }.reduce("", { (result, parent) -> String in
				return result + [parent.parentName, parent.suffix].flatMap{ $0 }.joined(separator: "/") + "/"
			}) ?? ""
			switch T.self {
			case is Conversation.Type:
				return (parents + "conversations/\(id)", params)
			case is UserMinimal.Type:
				return (parents + "users/\(id)", params)
			case is Message.Type:
				return (parents + "messages/\(id)", params)
			default:
				#if DEBUG
					fatalError("type not implemented: \(T.self)")
				#else
					return ("", [:])
				#endif
			}
		case .standalone:
			switch T.self {
			case is StarterData.Type:
				return ("conversations/starter", [:])
			default:
				#if DEBUG
					fatalError("type not implemented: \(T.self)")
				#else
					return ("", [:])
				#endif
			}
		}
	}
	
}

extension NetworkResource: Equatable {
	public static func ==(lhs: NetworkResource<T>, rhs: NetworkResource<T>) -> Bool {
		switch (lhs, rhs) {
		case (.url(let lhs), .url(let rhs)):
			return lhs == rhs
		case (.id(_), .id(_)):
			#if DEBUG
				fatalError("Comparing 2 network resources doesn't really make sense")
			#else
				return false
			#endif
		case (.standalone, .standalone):
			return true
		default:
			break
		}
		
		return false
	}
}
