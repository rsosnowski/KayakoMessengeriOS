//
//  MessageCreationModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Wrap

public struct MessageCreateModel: WrapCustomizable {
	public let contents: String
	public let sourceChannel: SourceChannel
	public let clientID: String
	public let file: AttachmentCreationModel?
	
	public init(contents: String, sourceChannel: SourceChannel, clientID: String, file: AttachmentCreationModel?) {
		self.contents = contents
		self.sourceChannel = sourceChannel
		self.clientID = clientID
		self.file = file
	}
	
	public func keyForWrapping(propertyNamed propertyName: String) -> String? {
		switch propertyName {
		case "clientID":
			return "client_id"
		case "sourceChannel":
			return "source"
		default:
			return propertyName
		}
	}
}
