//
//  ConversationCreationModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Wrap
import Unbox

public struct ConversationCreateModel: Unboxable, WrapCustomizable {
	public let name: String
	public let subject: String
	public let contents: String
	public let email: String
	public let sourceChannel: SourceChannel?
	
	public init(name: String, subject: String, contents: String, email: String, sourceChannel: SourceChannel) {
		self.name = name
		self.subject = subject
		self.contents = contents
		self.email = email
		self.sourceChannel = sourceChannel
	}
	
	public init(unboxer: Unboxer) throws {
		self.name = try unboxer.unbox(key: "name")
		self.subject = try unboxer.unbox(key: "subject")
		self.contents = try unboxer.unbox(key: "contents")
		self.email = try unboxer.unbox(key: "email")
		self.sourceChannel = SourceChannel(text: try unboxer.unbox(key: "channel"))
	}
	
	public func keyForWrapping(propertyNamed propertyName: String) -> String? {
		if propertyName == "sourceChannel" {
			return "source"
		} else {
			return propertyName
		}
	}
}
