//
//  StarterData.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 14/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox

public struct StarterData: Unboxable {
	public let lastActiveAgents: [Resource<UserMinimal>]
	public let averageReplyTime: Float
	
	public init(unboxer: Unboxer) throws {
		self.lastActiveAgents = try unboxer.unbox(key: "last_active_agents")
		let optionalAverageReplyTime: Float? = try? unboxer.unbox(key: "average_reply_time")
		self.averageReplyTime = optionalAverageReplyTime ?? 0
	}
	
	public init(lastActiveAgents: [Resource<UserMinimal>], averageReplyTime: Float, activeConversations: [Resource<Conversation>]) {
		self.lastActiveAgents = lastActiveAgents
		self.averageReplyTime = averageReplyTime
	}
}
