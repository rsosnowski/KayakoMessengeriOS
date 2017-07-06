//
//  Conversation.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public struct Conversation: Unboxable {
	
	public let id: Int
	public let uuid: String
	public var requester: Resource<UserMinimal>
	public var creator: Resource<UserMinimal>
	public var lastReplier: Resource<UserMinimal>
	public let resourceURL: URL
	public let lastMessagePreview: String
	public let lastRepliedAt: Date
	public let lastAgentReplier: Resource<UserMinimal>?
	public let realtimeChannel: String
	public let isClosed: Bool
	public let statusID: Int?
	public let lastUpdatedAt: Date
	public let unreadCount: Int
	public var isTyping: Bool = false
	
	/// Initialize an instance of this model by unboxing a dictionary using an Unboxer
	public init(unboxer: Unboxer) throws {
		self.id = try unboxer.unbox(key: "id")
		self.uuid = try unboxer.unbox(key: "uuid")
		self.requester = try unboxer.unbox(key: "requester")
		self.creator = try unboxer.unbox(key: "creator")
		self.lastReplier = try unboxer.unbox(key: "last_replier")
		self.resourceURL = try unboxer.unbox(key: "resource_url")
		self.lastMessagePreview = try unboxer.unbox(key: "last_message_preview")
		self.lastRepliedAt = try iso8601Date(unboxer: unboxer, key: "last_replied_at")
		self.realtimeChannel = try unboxer.unbox(key: "realtime_channel")
		self.isClosed = try unboxer.unbox(key: "is_closed")
		self.lastAgentReplier = try? unboxer.unbox(key: "last_agent_replier")
		self.statusID = try? unboxer.unbox(keyPath: "status.id")
		self.lastUpdatedAt = try iso8601Date(unboxer: unboxer, key: "updated_at")
		self.unreadCount = try unboxer.unbox(keyPath: "read_marker.unread_count")
	}
	
}

extension Conversation: Equatable {
	public static func ==(lhs: Conversation, rhs: Conversation) -> Bool {
		return lhs.id == rhs.id
	}
}
