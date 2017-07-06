//
//  Rating.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public struct Rating: Unboxable {
	public let id: Int
	public let score: BotFeedbackType
	public let comment: String?
	
	
	public init(unboxer: Unboxer) throws {
		self.id = try unboxer.unbox(key: "id")
		self.score = try BotFeedbackType(text: unboxer.unbox(key: "score"))
		self.comment = try? unboxer.unbox(key: "comment")
	}
}
