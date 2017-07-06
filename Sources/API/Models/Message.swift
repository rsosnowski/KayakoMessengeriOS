//
//  Message.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 27/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public struct Message: Unboxable {
	public let id: Int
	public let subject: String
	public let contentText: String
	public var creator: Resource<UserMinimal>
	public let source: String?
	public let createdAt: Date
	public let updatedAt: Date
	public let resourceURL: URL
	public let clientID: String?
	public let status: MessageStatus?
	public let attachments: [Attachment]
	
	public init(unboxer: Unboxer) throws {
		self.id = try unboxer.unbox(key: "id")
		self.subject = try unboxer.unbox(key: "subject")
		self.contentText = try unboxer.unbox(key: "content_text")
		self.creator = try unboxer.unbox(key: "creator")
		self.source = unboxer.unbox(key: "source")
		self.createdAt = try iso8601Date(unboxer: unboxer, key: "created_at")
		self.updatedAt = try iso8601Date(unboxer: unboxer, key: "updated_at")
		self.resourceURL = try unboxer.unbox(key: "resource_url")
		self.clientID = try? unboxer.unbox(key: "client_id")
		self.status = try messageStatus(unboxer: unboxer, key: "message_status")
		self.attachments = try unboxer.unbox(key: "attachments")
	}
}
